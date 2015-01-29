var test = require('canvas-testbed');

console.log('page reloaded');

//called every frame
function render(context, width, height) {
    context.clearRect(0, 0, width, height);
    context.fillStyle = 'red';
    context.fillRect(250, 150, 200, 100);
}

//setup the testbed
test(render, {
    once: true
});