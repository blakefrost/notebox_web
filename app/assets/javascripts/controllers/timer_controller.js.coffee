app = angular.module("app")

app.controller "timerController", ['$scope', '$element', '$attrs', '$http', ($scope, $element, $attrs, $http) ->
  $scope.href = $attrs.href
  $scope.running = $attrs.running
  $scope.elaspedSeconds = $attrs.elaspedSeconds*1
  $scope.startTime = new XDate($attrs.startTime)

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

  $scope.startTimer = ->
    $scope.startTime = new XDate()
    $scope.intervalID = setInterval(tick, 200, this)

    # Put to the timer endpoint to start it.
    data =
      running: true
      start_time: $scope.startTime

    # Start timer on server
    $http.put $scope.href, data,
      success: (data, status, headers, config) ->
        console.log "success"
      error: (data, status, headers, config) ->
        console.log "error"

  $scope.stopTimer = ->
    clearInterval($scope.intervalID)
    now = new XDate()
    $scope.elaspedSeconds += Math.floor($scope.startTime.diffSeconds(now))

    data =
      running: false
      elasped_seconds: $scope.elaspedSeconds

    ## Stop timer on server
    $http.put $scope.href, data,
      success: (data, status, headers, config) ->
        console.log "success"
      error: (data, status, headers, config) ->
        console.log "error"

  $scope.toggle = ->
    $scope.running = !$scope.running
    if $scope.running
      $scope.startTimer()
    else
      $scope.stopTimer()

  pad = (n, width, z) ->
    z = z or "0"
    n = n + ""
    (if n.length >= width then n else new Array(width - n.length + 1).join(z) + n)

  $scope.formmattedElaspedTime = formatSeconds($scope.elaspedSeconds)

  if $scope.running
    $scope.intervalID = setInterval(tick, 200, this)


]
