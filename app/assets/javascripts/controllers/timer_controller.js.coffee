app = angular.module("app")

# TODO: Fix major bugs keeping timer from running correctly.

app.controller "timerController", ['$scope', '$element', '$attrs', '$http', ($scope, $element, $attrs, $http) ->
  $scope.running ?= false
  $scope.elaspedSeconds ?= 0

  if $scope.startTime
    $scope.startTime = new XDate($scope.startTime)
  else
    $scope.startTime = new XDate()

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
    @startTime = new XDate()
    @intervalID = setInterval(tick, 200, this)

    # Put to the timer endpoint to start it.
    data =
      running: true
      start_time: $scope.startTime

    # Start timer on server
    $http.put @href, data,
      success: (data, status, headers, config) ->
        console.log "success"
      error: (data, status, headers, config) ->
        console.log "error"

  $scope.stopTimer = ->
    now = new XDate()
    @elaspedSeconds += Math.floor(@startTime.diffSeconds(now))

    clearInterval(@intervalID)

    data =
      running: false
      elasped_seconds: Math.floor(@elaspedSeconds)

    ## Stop timer on server
    $http.put @href, data,
      success: (data, status, headers, config) ->
        console.log "success"
      error: (data, status, headers, config) ->
        console.log "error"

  $scope.toggle = ->
    @running = !@running
    if @running
      @startTimer()
    else
      @stopTimer()

  pad = (n, width, z) ->
    z = z or "0"
    n = n + ""
    (if n.length >= width then n else new Array(width - n.length + 1).join(z) + n)

  $scope.formmattedElaspedTime = formatSeconds($scope.elaspedSeconds)

  #if $scope.running
    #$scope.startTime = new XDate()
    #$scope.intervalID = setInterval(tick, 200, this)


]
