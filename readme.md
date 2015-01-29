# Browserify-Beefy-Tutorial #

## 对有基础的同学 ##

如果你比较了解 [`browserify`][1]  和 [`beefy`][2]，那么可以直接运行：`npm install` 安装所有的依赖包。

直接运行例子程序：

```
npm start -- examples/canvasTest.js
```

或者

```
npm start -- examples/rotatingTriangle.coffee
```

打开浏览器访问 `http://localhost:9966`。

通过阅读 `package.json`, `start.sh` 和 `examples/canvasTest.js` 就可以知道大致的用法了。

如果你不熟悉这种开发方法，请继续阅读。

## 概述 ##

传统写前端的代码，一定要写 HTML，往往也离不开单独的 JS 文件，或者还要写一些 CSS 文件。一个例子程序最少两个文件是省不掉的，多了三四个文件也很常见，可能还要包括一些外部引用 (jQuery, bootstrap 之类的)。

最近在准备 WebGL 的教程，需要快速地撰写例子代码。WebGL 的用例代码和一般的网页开发教程不同，往往就是一个 `Canvas`，剩下的就是 `JavaScript` 代码了。如果你熟悉 Node.JS 那么就很适合用 [`browserify`][1]  和 [`beefy`][2]  来加快开发速度了。

让我们先来看看我的需求有哪些：

## 需求 ##

1. Web 页面需要提供一个 WebGL 类型的 `Canvas`。
2. Canvas 可以随着窗口拉伸而变化，其中内容自动刷新。
3. 能够调用 `requestAnimationFrame`，并且计算两次调用间的时间差，便于实现动画。
4. 一个显示 FPS (Frame Per Second) 的组件，能够显示当前的程序的执行帧率。
5. 一个 `Toggled Button`，让用户能够在 "启动" 和 "停止" 之间切换。
6. 支持键盘事件，用于简单的动画控制，例如速度。
7. 例子代码可以直接用 `CoffeeScript` 编写。
8. 易于安装和执行。
9. 开发调试时候支持 live-reload，这样调试效率会高很多。

## 局部安装 ##

大部分安装 [`browserify`][1] 和 [`beefy`][2] 的说明都是全局安装:

```
npm install -g browserify
```

，其实没有必要，完全可以局部安装到当前项目的目录下：

```
npm install browserify beefy coffee-script --save-dev
```

这样将把 [`browserify`][1]、[`beefy`][2] 和 `coffee-script` 都安装到当前目录的 `node_modules` 子目录下。

安装到全局目录(`/usr/local/bin`)的好处是只要安装一次，那么在各个项目中就无需重新安装，直接可以使用。安装到局部目录则可以避免不同项目间版本冲突，例如：老一些的项目只能和旧版本的 [`browserify`][1] 兼容，而新的项目在可以自由使用最新的 [`browserify`][1] 了。

我的习惯是尽量使用局部安装，仅对最常用的 Package 再多装一份全局的。

[`browserify`][1]、[`beefy`][2] 和 `coffee-script` 都会在 `node_modules\.bin` 下放置自己的可执行程序。

当你运行 `package.json` 中 `scripts` 节点定义的脚本（也称为 [`npm scripts`][3]）的时候，`node_modules\.bin` 会被加到搜索路径中。

所以运行 `npm test`、`npm start`，或者 `npm run your-script -- <args>`，都会到 `node_modules\.bin` 中来搜索可执行程序。

如果当前项目仅包含一个例子程序，那么现在的配置也就够了。

大部分基于 Node.JS 的全栈程序员往往都用过或听说过 [`browserify`][1]，不知道也没关系，可以直接到其网站获取详细信息 https://github.com/substack/node-browserify。

而 [`beefy`][2] 则很像 [`ecstatic`](https://github.com/jesusabdullah/node-ecstatic)，本身提供了一个静态的 Web 服务器。但是它被设计为和 [`browserify`][1] 紧密集成，让基于 [`browserify`][1] 的开发过程更加流畅，如下文。

## 运行 JavaScript 例子 ##

```
node_modules/.bin/beefy examples/canvasTest.js --live
```

用浏览器访问 `localhost:9966` ，可以看到浏览器中一个红色的矩形。

`--live` 意思是，当前目录下的文件变化时(包括 `node_modules` 中的文件)，页面将自动刷新。

[`beefy`][2] 实现这种 `live-reload` 的方式很轻巧，它直接在当前页面中嵌入了和服务器通信的脚本(`XHR`)，定时比对目标文档的时间戳，不同则调用 `window.location.reload` 进行刷新。所以用 [`beefy`][2] 的 `live-reload` 无需浏览器安装任何插件。

当 `--live` 开关打开后，[`beefy`][2] 或监视当前目录下所有文件，甚至包括 `node_modules` 子目录下的变化。

如果你希望执行 [`beefy`][2] 的时候直接打开缺省浏览器，那么加上 `--open` 参数即可：

```
node_modules/.bin/beefy examples/canvasTest.js --live --open
```

### `npm start` ###

如果嫌每次打入这么长一串路径繁琐，那么可以在 `paclage.json` 中设置 `scripts` 如下：

```
{
    ...
    "scripts": {
        "start": "beefy examples/canvasTest.js --live"
    },
    ...
}
```

这样你每次只要键入 `npm start`，即可启动 [`beefy`][2]。[`npm scripts`][3] 在执行时，会缺省搜寻 `node_modules/.bin` 目录，因此我们不需要给 [`beefy`][2] 加上完整的路径。

### 参数 ###

可是我们每次需要运行的例子可能是不一样的，不都是 `canvasTest.js` (以我为例，我会将不同的例子放在 `examples` 目录下的不同文件中)。那么是否可以用传入的参数的方式来解决呢？答案是“不行”。

`npm 2.0` 之后，虽然可以通过 `--` 前缀来添加参数（`--`之后的所有内容都会被认为是参数），但是这个参数只会被添加到执行的命令的尾部，而不是像 `bash` 脚本那样，用 `$1`, `$2` 这样的方式来任意放置参数。

例如，`package.json` 的 `scripts` 声明如下

```
    "scripts": {
        "start": "beefy $1 --live"
    },
```

当你执行：

```
npm start -- examples/canvasTest.js
```

那么实际上执行的是

```
beefy $1 --live examples/canvasTest.js
```

`$1` 并没有被输入参数代入，`examples/canvasTest.js` 被插入到了我们不希望的尾部。

### 加一个过渡 shell ###

既然如此，就只能退化到 `shell` 方式了。创建一个脚本，命名为: `start.sh`，添加执行权限: `chmod +x start.sh`。内容如下：

```
beefy $1 --live
```

`package.json` 的 `scripts` 的内容是:

```
    "scripts": {
        "start": "./start.sh"
    },
```

这样，当你执行 `npm start -- examples/canvasTest.js` 实际执行的是：

```
beefy examples/canvasTest.js --live
```

这是我们想要的。

## canvas-testbed ##

因为有了 [`browserify`][1]，所以我们可以像写 Node.JS module 一样来写网页应用。最简单的例子就是 [`domready`](https://github.com/ded/domready)，可以让你在 JS 程序中用 Node.JS 方式来响应 `DOM Ready`事件 (浏览器兼容问题被封装在 `domread` package 里面了)，例如：

``` js
require('domready')(function () {
  $('body').html('<p>boosh</p>')
})
```

类似的专门用于 Web 前端开发的 Packages 很多，[`canvas-testbed`](https://github.com/mattdesl/canvas-testbed) 是专门用于 2D 或 WebGL Canvas 测试的 package。它会在 DOM 上自动添加一个 Canvas Element，响应 Window Resize 事件，甚至支持 `requestAnimationFrame` 动画回调，自动计算两次回调之间的时间差等。

具体用法请参见它自己的 GitHub Repo. (https://github.com/mattdesl/canvas-testbed).

我们这个教程就用到了: [`canvas-testbed`](https://github.com/mattdesl/canvas-testbed)，[`toggle-button`](https://github.com/jacobbubu/toggle-button)，[`fps-component`](https://www.npmjs.com/package/fps-component#readme)，[`webgl-context`](https://github.com/mattdesl/webgl-context)，[`keydown`](https://github.com/maxogden/keydown) 和 [`gl-clear`](https://github.com/hughsk/gl-clear)。

## 支持 `CoffeeScript` ##

如果要直接支持 CoffeeScript 编写的用例，那么需要配置 [`browserify`][1] 以支持 `CoffeeScript`。这需要做两个工作。

### coffeeify ###

第一个工作是为 [`browserify`][1] 配置 `transform` 插件：

```
npm install coffeeify --save-dev
```

`coffeeify` 完成将 `CoffeeScript` 源程序编译为 `JavaScript`，并且提供适合 [`browserify`][1] 消费的 `stream` 接口。

然后在 `package.json` 中添加配置项：

```
  "browserify": {
    "transform": [
      "coffeeify"
    ]
  }
```

[`browserify`][1] 会读取 `package.json` 中的配置信息。

### extension ###

第二个工作是把 `.coffee` 文件扩展名添加到 [`browserify`][1] 可以默认载入的扩展名列表中，获得等同于 `.js` 的地位。这样，当你的代码中有 `requrie './ex01'` 这样的引用，[`browserify`][1] 可以将 `ex01.coffee` 这样的文件引入，否则你就必须显示地写成 `requrie './ex01.coffee'`，感觉不太优雅。

这个参数只要添加到 `start.sh` 中即可，如下：

```
beefy $1 --live -- --extension='.coffee'
```

[`beefy`][2] 参数中的 `--` 表示其后的参数将被直接传递给 [`browserify`][1]。

最后，你可以试试

```
npm start -- examples/rotatingTriangle.coffee
```

可以看到一个旋转的三角形，以及 [FPS Meter](https://www.npmjs.com/package/fps-component#readme)，还有一个控制动画的 [toggled button](https://github.com/jacobbubu/toggle-button)。你还可以试试用上下方向键调整三角形的旋转速度。

所有这些都是通过 `Node.JS` Packages 来组合完成的，不需要创建自己的 HTML 和 CSS 文件。

## 总结 ##

[`browserify`][1]  和 [`beefy`][2] 这种方法缺点就是对网页本身的 Looks and Feel 的控制能力比较弱。但是对于做实验和样例非常方面，也很有乐趣。

Enjoy! 🐑

[1]: https://github.com/substack/node-browserify
[2]: https://github.com/chrisdickinson/beefy
[3]: https://docs.npmjs.com/misc/scripts