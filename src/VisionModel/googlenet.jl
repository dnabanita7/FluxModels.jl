export googlenet

function conv_block(inplanes, outplanes, stride, pad, kernel_size)
  conv_layer = Chain(Conv(kernel_size, inplanes => outplanes, stride = stride, pad = pad),
                     BatchNorm(outplanes, relu))
  return conv_layer
end

function inception_block(inplanes, out_1x1, red_3x3, out_3x3, red_5x5, out_5x5 out_1x1pool)
  inception_layer = Chain(conv_block(inplanes, out_1x1, kernel_size=(1,1)),
                          conv_block(inplanes, red_3x3, kernel_size=(1,1))
                          conv_block(red_3x3, out_3x3, pad=1, kernel_size=(3,3)),
                          conv_block(inplanes, red_5x5, kernel_size=(1,1)),
                          conv_block(red_5x5, out_5x5, pad=2, kernel_size=(5,5)),
                          MaxPool((3, 3), stride=1, pad=1),
                          conv_block(inplanes, out_1x1pool, kernel_size=(1,1)))
  return inception_layer
end

function googlenet(inplanes, )
  layers = Chain(conv_block(inplanes=3, outplanes=64, stride=2, pad=3, kernel_size=(7,7)),
                 MaxPool((3,3), stride=2, pad=1),
                 conv_block(inplanes=64, outplanes=192, stride=1, pad=1, kernel_size=(3,3)),
                 MaxPool((3,3), stride=2, pad=1),
                 inception_block(192, 64, 96, 128, 16, 32, 32),
                 inception_block(256, 128, 128, 192, 32, 96, 64),
                 MaxPool((3,3), stride=2, pad=1),
                 inception_block(480, 192, 96, 208, 16, 48, 64),
                 inception_block(512, 160, 112, 224, 24, 64, 64),
                 inception_block(512, 128, 128, 256, 24, 64, 64),
                 inception_block(512, 112, 144, 288, 32, 64, 64),
                 inception_block(528, 256, 160, 320, 32, 128, 128),
                 MaxPool((3,3), stride=2, pad=1),
                 inception_block(832, 256, 160, 320, 32, 128, 128),
                 inception_block(832, 384, 192, 384, 48, 128, 128),
                 AdaptiveMeanPool((1,1)),
                 flatten(),
                 Dropout(0.2),
                 Dense(1024, 1000))
  Flux.testmode!(layers, false)
  return layers
end