# GameEngine
A rather creatively named 2D game engine written in Swift using the Metal API. I pretty much only make tile based games and this engine is very geared towards doing that efficiently.

It currently only works on iOS but I have plans to extend it to tvOS and OSX at some point. (and maybe Linux via Vulkan)

# current state
This is very close to being ready to go. It could technically be used now.

Documentation can be [here](https://akoaysigod.github.io/GameEngine) a good portion of the public API has been documented.

## A few things left to do are:
- texture animation
- fix the data structures for font rendering
- fix up the text rendering shaders to have more options
- fix up text rendering in general, can probably move it over to the sprite pipeline.
- lighting system, probably will do next
- port to Vulkan, someday
- ensure that the rendering engine is as performant as it can be

I'm pretty sure this is as fast as it'll ever be. It seems rather slow or maybe it's because I'm kind of new to this. I can render 100 textured quads at ~15% CPU or 1.1ms CPU/GPU frame time. At 10000 I start to lose FPS. That is way more than I'll ever need for the game I'm making.

# Should you use it?
Probably not. I was having some performance issues using SpriteKit and I think (hope) this will address those issues but I don't know what I'm doing really. This will also never be as robust as SpriteKit as I have fairly specific needs.

With that being said, feel free to use it.

# howto
If you know SpriteKit you can probably skip this. One thing worth keeping in mind is the `TextNode` will take a really long time to create with no compiler optimization. The algorithm is pretty intense and the array bound checking kills it. It's worth running once with optimizations to force the font textures to be saved to disk.

To just test stuff out you can just build the `GameEngineTest` target which is not actually a unit test target.
The `TestGameViewController` is already setup to display some stuff.

Otherwise, subclass `GameViewController` and in `viewDidLoad()`:

```swift
if let view = self.view as? GameView {
  scene = Scene(size: view.bounds.size)
  view.presentScene(scene)
}

//this should probably be done in a subclass of `Scene` where it's easier to override the update method
let sprite = Sprite(named: "AnImageYouAdded")
scene.addNode(sprite)
```

And you should see the sprite at the bottom left corner of the screen.
