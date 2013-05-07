(angular.module 'app')
.controller 'mathmoController', [
  '$scope'
  '$window'
  'config'
  'questionStore'
  '$timeout'
  '$routeParams'
  ($scope, $window, config, qStore, $timeout, $routeParams) ->

    $scope._exName = null
    $scope._topic = null
    $scope._qNo = 0

    if $routeParams
      $scope.resourceId = $routeParams.id ? 7088
      $scope.single = $routeParams.users != "class" 
      if $routeParams.ex?
        $scope._exName = $routeParams.x
      if $routeParams.topic?
        $scope._topic = $routeParams.t
      if $routeParams.qNo?
        $scope._qNo = $routeParams.q


    $scope.renderMath = ->
      $timeout ->
        MathJax.Hub.Queue ["Typeset", MathJax.Hub]
      , 10

    #
    # topic group selection
    #
    $scope.groups = config.groups

    #
    # Exercise tab panes
    #
    $scope.panes = []

    $scope.qStore = qStore

    gPrefix = '%GRAPH%'

    topicCounts = {}

    retrieveQ = (topicId, pane) ->
      name = pane.name

      topicCounts[name] ||= {}
      topicCounts[name][topicId] ||= 1

      seed = name+'/'+topicId+'/'+topicCounts[name][topicId]

      console.log "seed = #seed"

      Math.seedrandom seed

      maker = config.topicMakerById topicId
      qa = maker()

      console.log "q=", qa[0]
      console.log "a=", qa[1]

      question = {
        exName: name
        topicId: topicId
        topic: config.topicTitleById topicId
        graph: if maker.fn? then maker.fn.toString() else 'no fn'
        q:qa[0]
        a:qa[1]
        f:qa[2]
        g:qa[3]
        isCollapsed: true
        toggle: ->
          @isCollapsed = !@isCollapsed
        isGraph: ->
          if @a.indexOf(gPrefix) == 0 then 'graph' else 'html'
      }
      question.graphData = qa[2](qa[3]) if question.isGraph()=='graph'
      pane.questions.push question
      $scope.renderMath()
    
    similarQ = (question, index, inc) ->
      name = question.exName
      topicId = question.topicId

      topicCounts[name] ||= {}
      topicCounts[name][topicId] ||= 1
      j = (topicCounts[name][topicId] += inc)

      seed = name+'/'+topicId+'/'+j

      console.log "similar seed = #seed"

      Math.seedrandom seed

      maker = config.topicMakerById topicId
      qa = maker()

      console.log "q=", qa[0]
      console.log "a=", qa[1]

      question.graph = if maker.fn? then maker.fn.toString() else 'no fn'
      question.q = qa[0]
      question.a = qa[1]
      question.f = qa[2]
      question.g = qa[3]
      question.graphData = qa[2](qa[3]) if question.isGraph()=='graph'

      $scope.renderMath()

    $scope.prevOnTopic = (qa, index) ->
      similarQ(qa, index, -1)
    
    $scope.nextOnTopic = (qa, index) ->
      similarQ(qa, index, +1)
    
    $scope.topicAvailable = (topicId) ->
      pane = $scope.activePane
      return not topicCounts[pane.name]?[topicId]?

    $scope.appendQ = (topicId, pane = null) ->
      if pane == null
        pane = $scope.activePane
      qStore.appendQ pane.name, topicId
      retrieveQ(topicId, pane)
    
    qStore.list().forEach (name) ->
      p = {
        name: name
        qStore: qStore.getQSet(name)
        questions: []
        active: false
      }
      $scope.panes.push p

      p.qStore.forEach (topicId) ->
        retrieveQ topicId, p    

    $scope.newData = {name:""}

    $scope.addQSet = ->
      $scope.panes.push {
        name: $scope.newData.name
        qStore: qStore.newQSet($scope.newData.name)
        questions: []
        active: true
      }
      $scope.newData.name = ""

    $scope.delQSet = (paneIndex) ->
      pane = $scope.panes[paneIndex]
      qStore.remove(pane.name)
      $scope.panes.splice paneIndex, 1
      delete topicCounts[name]

    $scope.clearAll = ->
      qStore.clear()
      $scope.panes = []
      topicCounts := {}

    $scope.topicTitleById = (id) -> config.topicById(id)[0]


    #
    # About dialog
    #
    $scope.openAbout = -> $scope.aboutOpen = true
    $scope.closeAbout = -> $scope.aboutOpen = false;

    $scope.aboutOpts =
      backdropFade: true
      dialogFade:true

    #
    # AddQ dialog
    #
    $scope.openAddQ = (pane) ->
      $scope.activePane = pane
      $scope.addQOpen = true

    $scope.closeAddQ = ->
      $scope.addQOpen = false

    /*
    #
    # Add random Qs
    #
    # Keep track of available questions
    available = function(typeChar)
      availableQs[$scope.activePane]?[typeChar] = for topicId of config.topics when topicId.indexOf typeChar == 0 and $scope.topicAvailable(topicId)

    $scope.availableCore = (pane) ->
      coreQs = for topicId of config.topics when topicId.indexOf 'C' == 0 and $scope.topicAvailable(topicId)
      $scope.addCore = (pane) ->


      Object.keys(config.topics)
      .filter (topicId) -> topicId.indexOf 'C' == 0
      .

              <button class="btn" ng-show="moreCore(pane)" ng-click="addCore(pane)">Add core questions</button>
          <button class="btn" ng-show="moreFurther(pane)" ng-click="addFurther(pane)">Add further questions</button>
          <button class="btn" ng-show="moreStats(pane)" ng-click="addStats(pane)">Add statistics questions</button>
    */

    $scope.addQOpts =
      backdropFade: true
      dialogFade:true

    # Control visibility of sketch warnings
    # Close box is a 'do not show me again'
    swarnings = true
    $scope.closeSketchWarning = ->
      swarnings := false

    $scope.showSketchWarning = -> swarnings
]

