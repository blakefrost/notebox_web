app = angular.module("app")

app.controller "timerController", ['$scope', '$element', '$attrs', '$http', ($scope, $element, $attrs, $http) ->
  $scope.running = false
  $scope.formmattedElaspedTime = "00:00:00"
  $scope.elaspedSeconds = 0

  tick = ->
    $scope.$apply ->
      seconds = $scope.elaspedSeconds + ((new Date()).getTime() / 1000 - $scope.startTime)
      hours = Math.floor(seconds / 3600)
      seconds -= hours * 3600
      minutes = Math.floor(seconds / 60)
      seconds -= minutes * 60
      seconds = Math.floor(seconds)
      $scope.formmattedElaspedTime = "#{pad(hours, 2)}:#{pad(minutes, 2)}:#{pad(seconds, 2)}"


  $scope.toggle = ->
    $scope.running = !$scope.running
    if $scope.running
      $scope.startTime = (new Date()).getTime() / 1000
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

    else
      $scope.elaspedSeconds += ((new Date()).getTime() / 1000 - $scope.startTime)
      clearInterval($scope.intervalID)

      #data =
        #running: false
        #stopTime: $scope.startTime

      ## Stop timer on server
      #$http.put $scope.href, data,
        #success: (data, status, headers, config) ->
          #console.log "success"
        #error: (data, status, headers, config) ->
          #console.log "error"


  pad = (n, width, z) ->
    z = z or "0"
    n = n + ""
    (if n.length >= width then n else new Array(width - n.length + 1).join(z) + n)
]
