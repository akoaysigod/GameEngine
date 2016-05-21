# GameEngine
A rather creatively named 2D game engine written in Swift using the Metal API.

It currently only works on iOS but I have plans to extend it to tvOS and OSX at some point.

It's based off of SpriteKit so if you know that API this should be pretty straight forward to use. This will end up working slightly different as I'm currently rewriting it to be much more specific to tiled graphics
as I think I can get the performance to improve by a lot rather than trying to make a more general purpose game engine.

Part of the motivation to create this engine was to (learn how to make engines and) have a game engine that had access to the lower level internals of the engine but still have a working framework that didn't require
any lower level programming.

If you are feeling adventurous or want to learn a little more about rendering stuff using Metal this will eventually have enough exposed to create a custom pipeline without needing to know enough background math
or knowledge of the complete inner workings of Metal.

# current state
This is very close to being ready to go. It really just needs more testing and making sure the rendering makes sense and is efficient

Documentation can be [here](https://akoaysigod.github.io/GameEngine) a good portion of the public API has been documented but basically none of the rendering engine has been documented yet.

It's also very much so designed around tile sprites at the moment. See this [README.md](resources/README.md) for the relavent information about how that's currently implemented. I'd definitely be ok with removing this restriction.
Currently, the `TextureAtlas` classes is tied to this but I'd be totally ok with someone changing it to support other formats!

## A few things left to do are:
Main thing now is to get this as performant as possible.

- texture animation
- ensure that the rendering engine is as performant as it can be
  - I'm mostly worried about how textures are being loaded at the moment but I'm sure there are other things I don't fully understand
- fix the data structures for font rendering
- fix up the text rendering shaders to have more options

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
