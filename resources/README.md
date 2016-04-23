This game engine is basically designed around the fact that I'll only be using the same sized tile images for everything.

# build phase:

The script `AtlasGen.py` can be added to the build phase like so:

```bash
${PROJECT_DIR}/resources/AtlasGen.py YOURRESOURCES.xcassets OUTPUTIMAGE.xcassets OUTPUTDATA.xcassets
```

It will output two xcassets.

# image xcassets:
The first will contain the images, currently upside down, as one image. It will create a different image for each group in your original xcassets. It does not currently support groups nested greater than one deep, I think. The output name will be the name of the group and can be used for the name to create a `TextureAtlas`.

# data xcassets:
Similarly it will create a corresponding xcassets holding the JSON data for each image. It will have the same name as the image with a postfix of `@2x` or `@3x`. `TextureAtlas` will figure out which one to use based on the device.

# JSON format:
```json
{
  "OriginalImageName": {
    "size": {
      "height": Int,
      "width": Int
    },
    "frame": {
      "width": Int,
      "height": Int,
      "x": Int,
      "y": Int
    }
  },
  ...
}
```
