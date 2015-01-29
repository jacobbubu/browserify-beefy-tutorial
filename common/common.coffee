testbed = require 'canvas-testbed'
toggleButton = require 'toggle-button'
Stats = require 'fps-component'
getGL = require 'webgl-context'

module.exports = (ready, render, vshader, fshader) ->
    gl = null
    stats = new Stats()
    stats.setMode 0 # 0: fps, 1: ms

    renderWrapper = (argv...) ->
        if render?
            canvasApp = @
            stats.begin()
            render.apply canvasApp, argv
            stats.end()

    readyWrapper = (context, width, height) ->
        canvasApp = @
        gl = getGL @

        # load FPF meter
        stats.domElement.style.position = 'absolute'
        stats.domElement.style.left = '0px'
        stats.domElement.style.top = '0px'
        stats.domElement.style.width = '86px'

        document.body.appendChild stats.domElement

        toggleButton (button, stopped) ->
            if canvasApp?
                if stopped
                    canvasApp.stop()
                else
                    canvasApp.start()
        , toRight: 0

        ready.call canvasApp, gl if initShaders(vshader, fshader) and ready?
        canvasApp.resize canvasApp.width, canvasApp.height

    loadShader = (type, source) ->
        # Create shader object
        shader = gl.createShader type
        if not shader?
            console.error 'unable to create shader'
            return null

        # Set the shader program
        gl.shaderSource shader, source

        # Compile the shader
        gl.compileShader shader

        # Check the result of compilation
        compiled = gl.getShaderParameter shader, gl.COMPILE_STATUS
        if not compiled
            error = gl.getShaderInfoLog shader
            console.error 'Failed to compile shader: ' + error
            gl.deleteShader shader
            return null

        shader

    createProgram = (vshader, fshader) ->
        # Create shader object
        if vshader?
            vertexShader = loadShader gl.VERTEX_SHADER, vshader
            return null if !vertexShader

        if fshader?
            fragmentShader = loadShader gl.FRAGMENT_SHADER, fshader
            return null if !fragmentShader

        # Create a program object
        program = gl.createProgram()
        return null if !program

        # Attach the shader objects
        gl.attachShader program, vertexShader if vertexShader?
        gl.attachShader program, fragmentShader if fragmentShader?

        # Link the program object
        gl.linkProgram program

        # Check the result of linking
        linked = gl.getProgramParameter program, gl.LINK_STATUS
        if !linked
            error = gl.getProgramInfoLog program
            console.log 'Failed to link program: ' + error
            gl.deleteProgram program
            gl.deleteShader fragmentShader if fragmentShader?
            gl.deleteShader vertexShader if vertexShader?
            null
        else
            program

    initShaders = (vshader, fshader) ->
        return true if not (vshader? and fshader?)

        program = createProgram vshader, fshader
        if !program
            console.error 'Failed to create program'
            return false

        gl.useProgram program
        gl.program = program
        true

    # setup the testbed
    testbed renderWrapper, {
        context: 'webgl'
        contextAttributes:
            antialias: true
        onReady: readyWrapper
        resizeDebounce: 0
    }