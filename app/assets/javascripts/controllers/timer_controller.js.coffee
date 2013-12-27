app = angular.module("app")

app.controller "timerController", ['$scope', '$element', '$attrs', '$http', ($scope, $element, $attrs, $http) ->
  $scope.running = false
  $scope.formmattedElaspedTime = "00:00:00"
  $scope.elaspedSeconds = 0

  formatSeconds = (seconds) ->
    hours = Math.floor(seconds / 3600)
    seconds -= hours * 3600
    minutes = Math.floor(seconds / 60)
    seconds -= minutes * 60
    seconds = Math.floor(seconds)
    $scope.formmattedElaspedTime = "#{pad(hours, 2)}:#{pad(minutes, 2)}:#{pad(seconds, 2)}"

  tick = ->
    $scope.$apply ->
      now = new XDate()
      seconds = $scope.elaspedSeconds + $scope.startTime.diffSeconds(now)
      $scope.formmattedElaspedTime = formatSeconds(seconds)

  startTimer = ->
    $scope.startTime = new XDate()
    $scope.intervalID = setInterval(tick, 200, this)

    # Put to the timer endpoint to start it.
    data =
      startTime: $scope.startTime
      running: true

    # Start timer on server
    $http.put $scope.href, data,
      success: (data, status, headers, config) ->
        console.log "success"
      error: (data, status, headers, config) ->
        console.log "error"

  stopTimer = ->
    now = new XDate()
    $scope.elaspedSeconds += Math.floor($scope.startTime.diffSeconds(now))

    clearInterval($scope.intervalID)

    data =
      running: false
      elaspedSeconds: Math.floor($scope.elaspedSeconds)

    ## Stop timer on server
    $http.put $scope.href, data,
      success: (data, status, headers, config) ->
        console.log "success"
      error: (data, status, headers, config) ->
        console.log "error"

  $scope.toggle = ->
    $scope.running = !$scope.running
    if $scope.running
      startTimer()
    else
      stopTimer()

  pad = (n, width, z) ->
    z = z or "0"
    n = n + ""
    (if n.length >= width then n else new Array(width - n.length + 1).join(z) + n)
]
