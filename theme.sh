#!/bin/sh

# Written by Aetnaeus.
# Source: https://github.com/lemnos/theme.sh.
# Licensed under the WTFPL provided this notice is preserved.

themes=$(cat <<!
3024-day
0: #090300
1: #db2d20
2: #01a252
3: #fded02
4: #01a0e4
5: #a16a94
6: #b5e4f4
7: #a5a2a2
8: #5c5855
9: #e8bbd0
10: #3a3432
11: #4a4543
12: #807d7c
13: #d6d5d4
14: #cdab53
15: #f7f7f7
background: #f7f7f7
foreground: #4a4543
cursorColor: #4a4543

3024-night
0: #090300
1: #db2d20
2: #01a252
3: #fded02
4: #01a0e4
5: #a16a94
6: #b5e4f4
7: #a5a2a2
8: #5c5855
9: #e8bbd0
10: #3a3432
11: #4a4543
12: #807d7c
13: #d6d5d4
14: #cdab53
15: #f7f7f7
background: #090300
foreground: #a5a2a2
cursorColor: #a5a2a2

aci
0: #363636
1: #ff0883
2: #83ff08
3: #ff8308
4: #0883ff
5: #8308ff
6: #08ff83
7: #b6b6b6
8: #424242
9: #ff1e8e
10: #8eff1e
11: #ff8e1e
12: #1e8eff
13: #8e1eff
14: #1eff8e
15: #c2c2c2
background: #0d1926
foreground: #b4e1fd
cursorColor: #b4e1fd

aco
0: #3f3f3f
1: #ff0883
2: #83ff08
3: #ff8308
4: #0883ff
5: #8308ff
6: #08ff83
7: #bebebe
8: #474747
9: #ff1e8e
10: #8eff1e
11: #ff8e1e
12: #1e8eff
13: #8e1eff
14: #1eff8e
15: #c4c4c4
background: #1f1305
foreground: #b4e1fd
cursorColor: #b4e1fd

adventuretime
0: #050404
1: #bd0013
2: #4ab118
3: #e7741e
4: #0f4ac6
5: #665993
6: #70a598
7: #f8dcc0
8: #4e7cbf
9: #fc5f5a
10: #9eff6e
11: #efc11a
12: #1997c6
13: #9b5953
14: #c8faf4
15: #f6f5fb
background: #1f1d45
foreground: #f8dcc0
cursorColor: #f8dcc0

afterglow
0: #151515
1: #a53c23
2: #7b9246
3: #d3a04d
4: #6c99bb
5: #9f4e85
6: #7dd6cf
7: #d0d0d0
8: #505050
9: #a53c23
10: #7b9246
11: #d3a04d
12: #547c99
13: #9f4e85
14: #7dd6cf
15: #f5f5f5
background: #222222
foreground: #d0d0d0
cursorColor: #d0d0d0

alien-blood
0: #112616
1: #7f2b27
2: #2f7e25
3: #717f24
4: #2f6a7f
5: #47587f
6: #327f77
7: #647d75
8: #3c4812
9: #e08009
10: #18e000
11: #bde000
12: #00aae0
13: #0058e0
14: #00e0c4
15: #73fa91
background: #0f1610
foreground: #637d75
cursorColor: #637d75

argonaut
0: #232323
1: #ff000f
2: #8ce10b
3: #ffb900
4: #008df8
5: #6d43a6
6: #00d8eb
7: #ffffff
8: #444444
9: #ff2740
10: #abe15b
11: #ffd242
12: #0092ff
13: #9a5feb
14: #67fff0
15: #ffffff
background: #0e1019
foreground: #fffaf4
cursorColor: #fffaf4

arthur
0: #3d352a
1: #cd5c5c
2: #86af80
3: #e8ae5b
4: #6495ed
5: #deb887
6: #b0c4de
7: #bbaa99
8: #554444
9: #cc5533
10: #88aa22
11: #ffa75d
12: #87ceeb
13: #996600
14: #b0c4de
15: #ddccbb
background: #1c1c1c
foreground: #ddeedd
cursorColor: #ddeedd

atom
0: #000000
1: #fd5ff1
2: #87c38a
3: #ffd7b1
4: #85befd
5: #b9b6fc
6: #85befd
7: #e0e0e0
8: #000000
9: #fd5ff1
10: #94fa36
11: #f5ffa8
12: #96cbfe
13: #b9b6fc
14: #85befd
15: #e0e0e0
background: #161719
foreground: #c5c8c6
cursorColor: #c5c8c6

azu
0: #000000
1: #ac6d74
2: #74ac6d
3: #aca46d
4: #6d74ac
5: #a46dac
6: #6daca4
7: #e6e6e6
8: #262626
9: #d6b8bc
10: #bcd6b8
11: #d6d3b8
12: #b8bcd6
13: #d3b8d6
14: #b8d6d3
15: #ffffff
background: #09111a
foreground: #d9e6f2
cursorColor: #d9e6f2

belafonte-day
0: #20111b
1: #be100e
2: #858162
3: #eaa549
4: #426a79
5: #97522c
6: #989a9c
7: #968c83
8: #5e5252
9: #be100e
10: #858162
11: #eaa549
12: #426a79
13: #97522c
14: #989a9c
15: #d5ccba
background: #d5ccba
foreground: #45373c
cursorColor: #45373c

belafonte-night
0: #20111b
1: #be100e
2: #858162
3: #eaa549
4: #426a79
5: #97522c
6: #989a9c
7: #968c83
8: #5e5252
9: #be100e
10: #858162
11: #eaa549
12: #426a79
13: #97522c
14: #989a9c
15: #d5ccba
background: #20111b
foreground: #968c83
cursorColor: #968c83

bim
0: #2c2423
1: #f557a0
2: #a9ee55
3: #f5a255
4: #5ea2ec
5: #a957ec
6: #5eeea0
7: #918988
8: #918988
9: #f579b2
10: #bbee78
11: #f5b378
12: #81b3ec
13: #bb79ec
14: #81eeb2
15: #f5eeec
background: #012849
foreground: #a9bed8
cursorColor: #a9bed8

birds-of-paradise
0: #573d26
1: #be2d26
2: #6ba18a
3: #e99d2a
4: #5a86ad
5: #ac80a6
6: #74a6ad
7: #e0dbb7
8: #9b6c4a
9: #e84627
10: #95d8ba
11: #d0d150
12: #b8d3ed
13: #d19ecb
14: #93cfd7
15: #fff9d5
background: #2a1f1d
foreground: #e0dbb7
cursorColor: #e0dbb7

blazer
0: #000000
1: #b87a7a
2: #7ab87a
3: #b8b87a
4: #7a7ab8
5: #b87ab8
6: #7ab8b8
7: #d9d9d9
8: #262626
9: #dbbdbd
10: #bddbbd
11: #dbdbbd
12: #bdbddb
13: #dbbddb
14: #bddbdb
15: #ffffff
background: #0d1926
foreground: #d9e6f2
cursorColor: #d9e6f2

borland
0: #4f4f4f
1: #ff6c60
2: #a8ff60
3: #ffffb6
4: #96cbfe
5: #ff73fd
6: #c6c5fe
7: #eeeeee
8: #7c7c7c
9: #ffb6b0
10: #ceffac
11: #ffffcc
12: #b5dcff
13: #ff9cfe
14: #dfdffe
15: #ffffff
background: #0000a4
foreground: #ffff4e
cursorColor: #ffff4e

broadcast
0: #000000
1: #da4939
2: #519f50
3: #ffd24a
4: #6d9cbe
5: #d0d0ff
6: #6e9cbe
7: #ffffff
8: #323232
9: #ff7b6b
10: #83d182
11: #ffff7c
12: #9fcef0
13: #ffffff
14: #a0cef0
15: #ffffff
background: #2b2b2b
foreground: #e6e1dc
cursorColor: #e6e1dc

brogrammer
0: #1f1f1f
1: #f81118
2: #2dc55e
3: #ecba0f
4: #2a84d2
5: #4e5ab7
6: #1081d6
7: #d6dbe5
8: #d6dbe5
9: #de352e
10: #1dd361
11: #f3bd09
12: #1081d6
13: #5350b9
14: #0f7ddb
15: #ffffff
background: #131313
foreground: #d6dbe5
cursorColor: #d6dbe5

c64
0: #090300
1: #883932
2: #55a049
3: #bfce72
4: #40318d
5: #8b3f96
6: #67b6bd
7: #ffffff
8: #000000
9: #883932
10: #55a049
11: #bfce72
12: #40318d
13: #8b3f96
14: #67b6bd
15: #f7f7f7
background: #40318d
foreground: #7869c4
cursorColor: #7869c4

cai
0: #000000
1: #ca274d
2: #4dca27
3: #caa427
4: #274dca
5: #a427ca
6: #27caa4
7: #808080
8: #808080
9: #e98da3
10: #a3e98d
11: #e9d48d
12: #8da3e9
13: #d48de9
14: #8de9d4
15: #ffffff
background: #09111a
foreground: #d9e6f2
cursorColor: #d9e6f2

chalkboard
0: #000000
1: #c37372
2: #72c373
3: #c2c372
4: #7372c3
5: #c372c2
6: #72c2c3
7: #d9d9d9
8: #323232
9: #dbaaaa
10: #aadbaa
11: #dadbaa
12: #aaaadb
13: #dbaada
14: #aadadb
15: #ffffff
background: #29262f
foreground: #d9e6f2
cursorColor: #d9e6f2

chalk
0: #646464
1: #F58E8E
2: #A9D3AB
3: #FED37E
4: #7AABD4
5: #D6ADD5
6: #79D4D5
7: #D4D4D4
8: #646464
9: #F58E8E
10: #A9D3AB
11: #FED37E
12: #7AABD4
13: #D6ADD5
14: #79D4D5
15: #D4D4D4
background: #2D2D2D
foreground: #D4D4D4
cursorColor: #D4D4D4

ciapre
0: #181818
1: #810009
2: #48513b
3: #cc8b3f
4: #576d8c
5: #724d7c
6: #5c4f4b
7: #aea47f
8: #555555
9: #ac3835
10: #a6a75d
11: #dcdf7c
12: #3097c6
13: #d33061
14: #f3dbb2
15: #f4f4f4
background: #191c27
foreground: #aea47a
cursorColor: #aea47a

clone-of-ubuntu
0: #2E3436
1: #CC0000
2: #4E9A06
3: #C4A000
4: #3465A4
5: #75507B
6: #06989A
7: #D3D7CF
8: #555753
9: #EF2929
10: #8AE234
11: #FCE94F
12: #729FCF
13: #AD7FA8
14: #34E2E2
15: #EEEEEC
background: #300a24
foreground: #ffffff
cursorColor: #ffffff

clrs
0: #000000
1: #f8282a
2: #328a5d
3: #fa701d
4: #135cd0
5: #9f00bd
6: #33c3c1
7: #b3b3b3
8: #555753
9: #fb0416
10: #2cc631
11: #fdd727
12: #1670ff
13: #e900b0
14: #3ad5ce
15: #eeeeec
background: #ffffff
foreground: #262626
cursorColor: #262626

cobalt2
0: #000000
1: #ff0000
2: #38de21
3: #ffe50a
4: #1460d2
5: #ff005d
6: #00bbbb
7: #bbbbbb
8: #555555
9: #f40e17
10: #3bd01d
11: #edc809
12: #5555ff
13: #ff55ff
14: #6ae3fa
15: #ffffff
background: #132738
foreground: #ffffff
cursorColor: #ffffff

cobalt-neon
0: #142631
1: #ff2320
2: #3ba5ff
3: #e9e75c
4: #8ff586
5: #781aa0
6: #8ff586
7: #ba46b2
8: #fff688
9: #d4312e
10: #8ff586
11: #e9f06d
12: #3c7dd2
13: #8230a7
14: #6cbc67
15: #8ff586
background: #142838
foreground: #8ff586
cursorColor: #8ff586

crayon-pony-fish
0: #2b1b1d
1: #91002b
2: #579524
3: #ab311b
4: #8c87b0
5: #692f50
6: #e8a866
7: #68525a
8: #3d2b2e
9: #c5255d
10: #8dff57
11: #c8381d
12: #cfc9ff
13: #fc6cba
14: #ffceaf
15: #b0949d
background: #150707
foreground: #68525a
cursorColor: #68525a

dark-pastel
0: #000000
1: #ff5555
2: #55ff55
3: #ffff55
4: #5555ff
5: #ff55ff
6: #55ffff
7: #bbbbbb
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
background: #000000
foreground: #ffffff
cursorColor: #ffffff

darkside
0: #000000
1: #e8341c
2: #68c256
3: #f2d42c
4: #1c98e8
5: #8e69c9
6: #1c98e8
7: #bababa
8: #000000
9: #e05a4f
10: #77b869
11: #efd64b
12: #387cd3
13: #957bbe
14: #3d97e2
15: #bababa
background: #222324
foreground: #bababa
cursorColor: #bababa

desert
0: #4d4d4d
1: #ff2b2b
2: #98fb98
3: #f0e68c
4: #cd853f
5: #ffdead
6: #ffa0a0
7: #f5deb3
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #87ceff
13: #ff55ff
14: #ffd700
15: #ffffff
background: #333333
foreground: #ffffff
cursorColor: #ffffff

dimmed-monokai
0: #3a3d43
1: #be3f48
2: #879a3b
3: #c5a635
4: #4f76a1
5: #855c8d
6: #578fa4
7: #b9bcba
8: #888987
9: #fb001f
10: #0f722f
11: #c47033
12: #186de3
13: #fb0067
14: #2e706d
15: #fdffb9
background: #1f1f1f
foreground: #b9bcba
cursorColor: #b9bcba

dracula
0: #44475a
1: #ff5555
2: #50fa7b
3: #ffb86c
4: #8be9fd
5: #bd93f9
6: #ff79c6
7: #94A3A5
8: #000000
9: #ff5555
10: #50fa7b
11: #ffb86c
12: #8be9fd
13: #bd93f9
14: #ff79c6
15: #ffffff
background: #282a36
foreground: #94A3A5
cursorColor: #94A3A5

earthsong
0: #121418
1: #c94234
2: #85c54c
3: #f5ae2e
4: #1398b9
5: #d0633d
6: #509552
7: #e5c6aa
8: #675f54
9: #ff645a
10: #98e036
11: #e0d561
12: #5fdaff
13: #ff9269
14: #84f088
15: #f6f7ec
background: #292520
foreground: #e5c7a9
cursorColor: #e5c7a9

elemental
0: #3c3c30
1: #98290f
2: #479a43
3: #7f7111
4: #497f7d
5: #7f4e2f
6: #387f58
7: #807974
8: #555445
9: #e0502a
10: #61e070
11: #d69927
12: #79d9d9
13: #cd7c54
14: #59d599
15: #fff1e9
background: #22211d
foreground: #807a74
cursorColor: #807a74

elementary
0: #303030
1: #e1321a
2: #6ab017
3: #ffc005
4: #004f9e
5: #ec0048
6: #2aa7e7
7: #f2f2f2
8: #5d5d5d
9: #ff361e
10: #7bc91f
11: #ffd00a
12: #0071ff
13: #ff1d62
14: #4bb8fd
15: #a020f0
background: #101010
foreground: #f2f2f2
cursorColor: #f2f2f2

elic
0: #303030
1: #e1321a
2: #6ab017
3: #ffc005
4: #729FCF
5: #ec0048
6: #f2f2f2
7: #2aa7e7
8: #5d5d5d
9: #ff361e
10: #7bc91f
11: #ffd00a
12: #0071ff
13: #ff1d62
14: #4bb8fd
15: #a020f0
background: #4A453E
foreground: #f2f2f2
cursorColor: #f2f2f2

elio
0: #303030
1: #e1321a
2: #6ab017
3: #ffc005
4: #729FCF
5: #ec0048
6: #2aa7e7
7: #f2f2f2
8: #5d5d5d
9: #ff361e
10: #7bc91f
11: #ffd00a
12: #0071ff
13: #ff1d62
14: #4bb8fd
15: #a020f0
background: #041A3B
foreground: #f2f2f2
cursorColor: #f2f2f2

espresso-libre
0: #000000
1: #cc0000
2: #1a921c
3: #f0e53a
4: #0066ff
5: #c5656b
6: #06989a
7: #d3d7cf
8: #555753
9: #ef2929
10: #9aff87
11: #fffb5c
12: #43a8ed
13: #ff818a
14: #34e2e2
15: #eeeeec
background: #2a211c
foreground: #b8a898
cursorColor: #b8a898

espresso
0: #353535
1: #d25252
2: #a5c261
3: #ffc66d
4: #6c99bb
5: #d197d9
6: #bed6ff
7: #eeeeec
8: #535353
9: #f00c0c
10: #c2e075
11: #e1e48b
12: #8ab7d9
13: #efb5f7
14: #dcf4ff
15: #ffffff
background: #323232
foreground: #ffffff
cursorColor: #ffffff

fishtank
0: #03073c
1: #c6004a
2: #acf157
3: #fecd5e
4: #525fb8
5: #986f82
6: #968763
7: #ecf0fc
8: #6c5b30
9: #da4b8a
10: #dbffa9
11: #fee6a9
12: #b2befa
13: #fda5cd
14: #a5bd86
15: #f6ffec
background: #232537
foreground: #ecf0fe
cursorColor: #ecf0fe

flatland
0: #1d1d19
1: #f18339
2: #9fd364
3: #f4ef6d
4: #5096be
5: #695abc
6: #d63865
7: #ffffff
8: #1d1d19
9: #d22a24
10: #a7d42c
11: #ff8949
12: #61b9d0
13: #695abc
14: #d63865
15: #ffffff
background: #1d1f21
foreground: #b8dbef
cursorColor: #b8dbef

flat
0: #2c3e50
1: #c0392b
2: #27ae60
3: #f39c12
4: #2980b9
5: #8e44ad
6: #16a085
7: #bdc3c7
8: #34495e
9: #e74c3c
10: #2ecc71
11: #f1c40f
12: #3498db
13: #9b59b6
14: #2AA198
15: #ecf0f1
background: #1F2D3A
foreground: #1abc9c
cursorColor: #1abc9c

foxnightly
0: #2A2A2E
1: #B98EFF
2: #FF7DE9
3: #729FCF
4: #66A05B
5: #75507B
6: #ACACAE
7: #FFFFFF
8: #A40000
9: #BF4040
10: #66A05B
11: #FFB86C
12: #729FCF
13: #8F5902
14: #C4A000
15: #5C3566
background: #2A2A2E
foreground: #D7D7DB
cursorColor: #D7D7DB

freya
0: #073642
1: #dc322f
2: #859900
3: #b58900
4: #268bd2
5: #ec0048
6: #2aa198
7: #94a3a5
8: #586e75
9: #cb4b16
10: #859900
11: #b58900
12: #268bd2
13: #d33682
14: #2aa198
15: #6c71c4
background: #252e32
foreground: #94a3a5
cursorColor: #839496

frontend-delight
0: #242526
1: #f8511b
2: #565747
3: #fa771d
4: #2c70b7
5: #f02e4f
6: #3ca1a6
7: #adadad
8: #5fac6d
9: #f74319
10: #74ec4c
11: #fdc325
12: #3393ca
13: #e75e4f
14: #4fbce6
15: #8c735b
background: #1b1c1d
foreground: #adadad
cursorColor: #adadad

frontend-fun-forrest
0: #000000
1: #d6262b
2: #919c00
3: #be8a13
4: #4699a3
5: #8d4331
6: #da8213
7: #ddc265
8: #7f6a55
9: #e55a1c
10: #bfc65a
11: #ffcb1b
12: #7cc9cf
13: #d26349
14: #e6a96b
15: #ffeaa3
background: #251200
foreground: #dec165
cursorColor: #dec165

frontend-galaxy
0: #000000
1: #f9555f
2: #21b089
3: #fef02a
4: #589df6
5: #944d95
6: #1f9ee7
7: #bbbbbb
8: #555555
9: #fa8c8f
10: #35bb9a
11: #ffff55
12: #589df6
13: #e75699
14: #3979bc
15: #ffffff
background: #1d2837
foreground: #ffffff
cursorColor: #ffffff

github
0: #3e3e3e
1: #970b16
2: #07962a
3: #f8eec7
4: #003e8a
5: #e94691
6: #89d1ec
7: #ffffff
8: #666666
9: #de0000
10: #87d5a2
11: #f1d007
12: #2e6cba
13: #ffa29f
14: #1cfafe
15: #ffffff
background: #f4f4f4
foreground: #3e3e3e
cursorColor: #3e3e3e

gooey
0: #000009
1: #BB4F6C
2: #72CCAE
3: #C65E3D
4: #58B6CA
5: #6488C4
6: #8D84C6
7: #858893
8: #1f222d
9: #ee829f
10: #a5ffe1
11: #f99170
12: #8be9fd
13: #97bbf7
14: #c0b7f9
15: #ffffff
background: #0D101B
foreground: #EBEEF9
cursorColor: #EBEEF9

google-dark
0: #1D1F21
1: #CC342B
2: #198844
3: #FBA922
4: #3971ED
5: #A36AC7
6: #3971ED
7: #C5C8C6
8: #969896
9: #CC342B
10: #198844
11: #FBA922
12: #3971ED
13: #A36AC7
14: #3971ED
15: #FFFFFF
background: #1D1F21
foreground: #B4B7B4
cursorColor: #B4B7B4

google-light
0: #FFFFFF
1: #CC342B
2: #198844
3: #FBA921
4: #3870ED
5: #A26AC7
6: #3870ED
7: #373B41
8: #C5C8C6
9: #CC342B
10: #198844
11: #FBA921
12: #3870ED
13: #A26AC7
14: #3870ED
15: #1D1F21
background: #FFFFFF
foreground: #373B41
cursorColor: #373B41

grape
0: #2d283f
1: #ed2261
2: #1fa91b
3: #8ddc20
4: #487df4
5: #8d35c9
6: #3bdeed
7: #9e9ea0
8: #59516a
9: #f0729a
10: #53aa5e
11: #b2dc87
12: #a9bcec
13: #ad81c2
14: #9de3eb
15: #a288f7
background: #171423
foreground: #9f9fa1
cursorColor: #9f9fa1

grass
0: #000000
1: #bb0000
2: #00bb00
3: #e7b000
4: #0000a3
5: #950062
6: #00bbbb
7: #bbbbbb
8: #555555
9: #bb0000
10: #00bb00
11: #e7b000
12: #0000bb
13: #ff55ff
14: #55ffff
15: #ffffff
background: #13773d
foreground: #fff0a5
cursorColor: #fff0a5

gruvbox-dark
0: #282828
1: #cc241d
2: #98971a
3: #d79921
4: #458588
5: #b16286
6: #689d6a
7: #a89984
8: #928374
9: #fb4934
10: #b8bb26
11: #fabd2f
12: #83a598
13: #d3869b
14: #8ec07c
15: #ebdbb2
background: #282828
foreground: #ebdbb2
cursorColor: #ebdbb2

gruvbox
0: #fbf1c7
1: #cc241d
2: #98971a
3: #d79921
4: #458588
5: #b16286
6: #689d6a
7: #7c6f64
8: #928374
9: #9d0006
10: #79740e
11: #b57614
12: #076678
13: #8f3f71
14: #427b58
15: #3c3836
background: #fbf1c7
foreground: #3c3836
cursorColor: #3c3836

hardcore
0: #1b1d1e
1: #f92672
2: #a6e22e
3: #fd971f
4: #66d9ef
5: #9e6ffe
6: #5e7175
7: #ccccc6
8: #505354
9: #ff669d
10: #beed5f
11: #e6db74
12: #66d9ef
13: #9e6ffe
14: #a3babf
15: #f8f8f2
background: #121212
foreground: #a0a0a0
cursorColor: #a0a0a0

harper
0: #010101
1: #f8b63f
2: #7fb5e1
3: #d6da25
4: #489e48
5: #b296c6
6: #f5bfd7
7: #a8a49d
8: #726e6a
9: #f8b63f
10: #7fb5e1
11: #d6da25
12: #489e48
13: #b296c6
14: #f5bfd7
15: #fefbea
background: #010101
foreground: #a8a49d
cursorColor: #a8a49d

hemisu-dark
0: #444444
1: #FF0054
2: #B1D630
3: #9D895E
4: #67BEE3
5: #B576BC
6: #569A9F
7: #EDEDED
8: #777777
9: #D65E75
10: #BAFFAA
11: #ECE1C8
12: #9FD3E5
13: #DEB3DF
14: #B6E0E5
15: #FFFFFF
background: #000000
foreground: #FFFFFF
cursorColor: #BAFFAA

hemisu-light
0: #777777
1: #FF0055
2: #739100
3: #503D15
4: #538091
5: #5B345E
6: #538091
7: #999999
8: #999999
9: #D65E76
10: #9CC700
11: #947555
12: #9DB3CD
13: #A184A4
14: #85B2AA
15: #BABABA
background: #EFEFEF
foreground: #444444
cursorColor: #FF0054

highway
0: #000000
1: #d00e18
2: #138034
3: #ffcb3e
4: #006bb3
5: #6b2775
6: #384564
7: #ededed
8: #5d504a
9: #f07e18
10: #b1d130
11: #fff120
12: #4fc2fd
13: #de0071
14: #5d504a
15: #ffffff
background: #222225
foreground: #ededed
cursorColor: #ededed

hipster-green
0: #000000
1: #b6214a
2: #00a600
3: #bfbf00
4: #246eb2
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #86a93e
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
background: #100b05
foreground: #84c138
cursorColor: #84c138

homebrew
0: #000000
1: #990000
2: #00a600
3: #999900
4: #0000b2
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
background: #000000
foreground: #00ff00
cursorColor: #00ff00

hurtado
0: #575757
1: #ff1b00
2: #a5e055
3: #fbe74a
4: #496487
5: #fd5ff1
6: #86e9fe
7: #cbcccb
8: #262626
9: #d51d00
10: #a5df55
11: #fbe84a
12: #89beff
13: #c001c1
14: #86eafe
15: #dbdbdb
background: #000000
foreground: #dbdbdb
cursorColor: #dbdbdb

hybrid
0: #282a2e
1: #A54242
2: #8C9440
3: #de935f
4: #5F819D
5: #85678F
6: #5E8D87
7: #969896
8: #373b41
9: #cc6666
10: #b5bd68
11: #f0c674
12: #81a2be
13: #b294bb
14: #8abeb7
15: #c5c8c6
background: #141414
foreground: #94a3a5
cursorColor: #94a3a5

ibm3270
0: #222222
1: #F01818
2: #24D830
3: #F0D824
4: #7890F0
5: #F078D8
6: #54E4E4
7: #A5A5A5
8: #888888
9: #EF8383
10: #7ED684
11: #EFE28B
12: #B3BFEF
13: #EFB3E3
14: #9CE2E2
15: #FFFFFF
background: #000000
foreground: #FDFDFD
cursorColor: #FDFDFD

ic-green-ppl
0: #1f1f1f
1: #fb002a
2: #339c24
3: #659b25
4: #149b45
5: #53b82c
6: #2cb868
7: #e0ffef
8: #032710
9: #a7ff3f
10: #9fff6d
11: #d2ff6d
12: #72ffb5
13: #50ff3e
14: #22ff71
15: #daefd0
background: #3a3d3f
foreground: #d9efd3
cursorColor: #d9efd3

ic-orange-ppl
0: #000000
1: #c13900
2: #a4a900
3: #caaf00
4: #bd6d00
5: #fc5e00
6: #f79500
7: #ffc88a
8: #6a4f2a
9: #ff8c68
10: #f6ff40
11: #ffe36e
12: #ffbe55
13: #fc874f
14: #c69752
15: #fafaff
background: #262626
foreground: #ffcb83
cursorColor: #ffcb83

idle-toes
0: #323232
1: #d25252
2: #7fe173
3: #ffc66d
4: #4099ff
5: #f680ff
6: #bed6ff
7: #eeeeec
8: #535353
9: #f07070
10: #9dff91
11: #ffe48b
12: #5eb7f7
13: #ff9dff
14: #dcf4ff
15: #ffffff
background: #323232
foreground: #ffffff
cursorColor: #ffffff

ir-black
0: #4e4e4e
1: #ff6c60
2: #a8ff60
3: #ffffb6
4: #69cbfe
5: #ff73Fd
6: #c6c5fe
7: #eeeeee
8: #7c7c7c
9: #ffb6b0
10: #ceffac
11: #ffffcb
12: #b5dcfe
13: #ff9cfe
14: #dfdffe
15: #ffffff
background: #000000
foreground: #eeeeee
cursorColor: ffa560

jackie-brown
0: #2c1d16
1: #ef5734
2: #2baf2b
3: #bebf00
4: #246eb2
5: #d05ec1
6: #00acee
7: #bfbfbf
8: #666666
9: #e50000
10: #86a93e
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
background: #2c1d16
foreground: #ffcc2f
cursorColor: #ffcc2f

japanesque
0: #343935
1: #cf3f61
2: #7bb75b
3: #e9b32a
4: #4c9ad4
5: #a57fc4
6: #389aad
7: #fafaf6
8: #595b59
9: #d18fa6
10: #767f2c
11: #78592f
12: #135979
13: #604291
14: #76bbca
15: #b2b5ae
background: #1e1e1e
foreground: #f7f6ec
cursorColor: #f7f6ec

jellybeans
0: #929292
1: #e27373
2: #94b979
3: #ffba7b
4: #97bedc
5: #e1c0fa
6: #00988e
7: #dedede
8: #bdbdbd
9: #ffa1a1
10: #bddeab
11: #ffdca0
12: #b1d8f6
13: #fbdaff
14: #1ab2a8
15: #ffffff
background: #121212
foreground: #dedede
cursorColor: #dedede

jup
0: #000000
1: #dd006f
2: #6fdd00
3: #dd6f00
4: #006fdd
5: #6f00dd
6: #00dd6f
7: #f2f2f2
8: #7d7d7d
9: #ff74b9
10: #b9ff74
11: #ffb974
12: #74b9ff
13: #b974ff
14: #74ffb9
15: #ffffff
background: #758480
foreground: #23476a
cursorColor: #23476a

kibble
0: #4d4d4d
1: #c70031
2: #29cf13
3: #d8e30e
4: #3449d1
5: #8400ff
6: #0798ab
7: #e2d1e3
8: #5a5a5a
9: #f01578
10: #6ce05c
11: #f3f79e
12: #97a4f7
13: #c495f0
14: #68f2e0
15: #ffffff
background: #0e100a
foreground: #f7f7f7
cursorColor: #f7f7f7

later-this-evening
0: #2b2b2b
1: #d45a60
2: #afba67
3: #e5d289
4: #a0bad6
5: #c092d6
6: #91bfb7
7: #3c3d3d
8: #454747
9: #d3232f
10: #aabb39
11: #e5be39
12: #6699d6
13: #ab53d6
14: #5fc0ae
15: #c1c2c2
background: #222222
foreground: #959595
cursorColor: #959595

lavandula
0: #230046
1: #7d1625
2: #337e6f
3: #7f6f49
4: #4f4a7f
5: #5a3f7f
6: #58777f
7: #736e7d
8: #372d46
9: #e05167
10: #52e0c4
11: #e0c386
12: #8e87e0
13: #a776e0
14: #9ad4e0
15: #8c91fa
background: #050014
foreground: #736e7d
cursorColor: #736e7d

liquid-carbon-transparent
0: #000000
1: #ff3030
2: #559a70
3: #ccac00
4: #0099cc
5: #cc69c8
6: #7ac4cc
7: #bccccc
8: #000000
9: #ff3030
10: #559a70
11: #ccac00
12: #0099cc
13: #cc69c8
14: #7ac4cc
15: #bccccc
background: #000000
foreground: #afc2c2
cursorColor: #afc2c2

liquid-carbon
0: #000000
1: #ff3030
2: #559a70
3: #ccac00
4: #0099cc
5: #cc69c8
6: #7ac4cc
7: #bccccc
8: #000000
9: #ff3030
10: #559a70
11: #ccac00
12: #0099cc
13: #cc69c8
14: #7ac4cc
15: #bccccc
background: #303030
foreground: #afc2c2
cursorColor: #afc2c2

maia
0: #232423
1: #BA2922
2: #7E807E
3: #4C4F4D
4: #16A085
5: #43746A
6: #00CCCC
7: #E0E0E0
8: #282928
9: #CC372C
10: #8D8F8D
11: #4E524F
12: #13BF9D
13: #487D72
14: #00D1D1
15: #E8E8E8
background: #272827
foreground: #fdf6e3
cursorColor: #16A085

man-page
0: #000000
1: #cc0000
2: #00a600
3: #999900
4: #0000b2
5: #b200b2
6: #00a6b2
7: #cccccc
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
background: #fef49c
foreground: #000000
cursorColor: #000000

mar
0: #000000
1: #b5407b
2: #7bb540
3: #b57b40
4: #407bb5
5: #7b40b5
6: #40b57b
7: #f8f8f8
8: #737373
9: #cd73a0
10: #a0cd73
11: #cda073
12: #73a0cd
13: #a073cd
14: #73cda0
15: #ffffff
background: #ffffff
foreground: #23476a
cursorColor: #23476a

material
0: #073641
1: #EB606B
2: #C3E88D
3: #F7EB95
4: #80CBC3
5: #FF2490
6: #AEDDFF
7: #FFFFFF
8: #002B36
9: #EB606B
10: #C3E88D
11: #F7EB95
12: #7DC6BF
13: #6C71C3
14: #34434D
15: #FFFFFF
background: #1E282C
foreground: #C3C7D1
cursorColor: #657B83

mathias
0: #000000
1: #e52222
2: #a6e32d
3: #fc951e
4: #c48dff
5: #fa2573
6: #67d9f0
7: #f2f2f2
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
background: #000000
foreground: #bbbbbb
cursorColor: #bbbbbb

medallion
0: #000000
1: #b64c00
2: #7c8b16
3: #d3bd26
4: #616bb0
5: #8c5a90
6: #916c25
7: #cac29a
8: #5e5219
9: #ff9149
10: #b2ca3b
11: #ffe54a
12: #acb8ff
13: #ffa0ff
14: #ffbc51
15: #fed698
background: #1d1908
foreground: #cac296
cursorColor: #cac296

misterioso
0: #000000
1: #ff4242
2: #74af68
3: #ffad29
4: #338f86
5: #9414e6
6: #23d7d7
7: #e1e1e0
8: #555555
9: #ff3242
10: #74cd68
11: #ffb929
12: #23d7d7
13: #ff37ff
14: #00ede1
15: #ffffff
background: #2d3743
foreground: #e1e1e0
cursorColor: #e1e1e0

miu
0: #000000
1: #b87a7a
2: #7ab87a
3: #b8b87a
4: #7a7ab8
5: #b87ab8
6: #7ab8b8
7: #d9d9d9
8: #262626
9: #dbbdbd
10: #bddbbd
11: #dbdbbd
12: #bdbddb
13: #dbbddb
14: #bddbdb
15: #ffffff
background: #0d1926
foreground: #d9e6f2
cursorColor: #d9e6f2

molokai
0: #1b1d1e
1: #7325FA
2: #23E298
3: #60D4DF
4: #D08010
5: #FF0087
6: #D0A843
7: #BBBBBB
8: #555555
9: #9D66F6
10: #5FE0B1
11: #6DF2FF
12: #FFAF00
13: #FF87AF
14: #FFCE51
15: #FFFFFF
background: #1b1d1e
foreground: #BBBBBB
cursorColor: #BBBBBB

mona-lisa
0: #351b0e
1: #9b291c
2: #636232
3: #c36e28
4: #515c5d
5: #9b1d29
6: #588056
7: #f7d75c
8: #874228
9: #ff4331
10: #b4b264
11: #ff9566
12: #9eb2b4
13: #ff5b6a
14: #8acd8f
15: #ffe598
background: #120b0d
foreground: #f7d66a
cursorColor: #f7d66a

mono-amber
0: #402500
1: #FF9400
2: #FF9400
3: #FF9400
4: #FF9400
5: #FF9400
6: #FF9400
7: #FF9400
8: #FF9400
9: #FF9400
10: #FF9400
11: #FF9400
12: #FF9400
13: #FF9400
14: #FF9400
15: #FF9400
background: #2B1900
foreground: #FF9400
cursorColor: #FF9400

mono-cyan
0: #003340
1: #00CCFF
2: #00CCFF
3: #00CCFF
4: #00CCFF
5: #00CCFF
6: #00CCFF
7: #00CCFF
8: #00CCFF
9: #00CCFF
10: #00CCFF
11: #00CCFF
12: #00CCFF
13: #00CCFF
14: #00CCFF
15: #00CCFF
background: #00222B
foreground: #00CCFF
cursorColor: #00CCFF

mono-green
0: #034000
1: #0BFF00
2: #0BFF00
3: #0BFF00
4: #0BFF00
5: #0BFF00
6: #0BFF00
7: #0BFF00
8: #0BFF00
9: #0BFF00
10: #0BFF00
11: #0BFF00
12: #0BFF00
13: #0BFF00
14: #0BFF00
15: #0BFF00
background: #022B00
foreground: #0BFF00
cursorColor: #0BFF00

monokai-dark
0: #75715e
1: #f92672
2: #a6e22e
3: #f4bf75
4: #66d9ef
5: #ae81ff
6: #2AA198
7: #f9f8f5
8: #272822
9: #f92672
10: #a6e22e
11: #f4bf75
12: #66d9ef
13: #ae81ff
14: #2AA198
15: #f8f8f2
background: #272822
foreground: #f8f8f2
cursorColor: #f8f8f2

monokai-soda
0: #1a1a1a
1: #f4005f
2: #98e024
3: #fa8419
4: #9d65ff
5: #f4005f
6: #58d1eb
7: #c4c5b5
8: #625e4c
9: #f4005f
10: #98e024
11: #e0d561
12: #9d65ff
13: #f4005f
14: #58d1eb
15: #f6f6ef
background: #1a1a1a
foreground: #c4c5b5
cursorColor: #c4c5b5

mono-red
0: #401200
1: #FF3600
2: #FF3600
3: #FF3600
4: #FF3600
5: #FF3600
6: #FF3600
7: #FF3600
8: #FF3600
9: #FF3600
10: #FF3600
11: #FF3600
12: #FF3600
13: #FF3600
14: #FF3600
15: #FF3600
background: #2B0C00
foreground: #FF3600
cursorColor: #FF3600

mono-white
0: #3B3B3B
1: #FAFAFA
2: #FAFAFA
3: #FAFAFA
4: #FAFAFA
5: #FAFAFA
6: #FAFAFA
7: #FAFAFA
8: #FAFAFA
9: #FAFAFA
10: #FAFAFA
11: #FAFAFA
12: #FAFAFA
13: #FAFAFA
14: #FAFAFA
15: #FAFAFA
background: #262626
foreground: #FAFAFA
cursorColor: #FAFAFA

mono-yellow
0: #403500
1: #FFD300
2: #FFD300
3: #FFD300
4: #FFD300
5: #FFD300
6: #FFD300
7: #FFD300
8: #FFD300
9: #FFD300
10: #FFD300
11: #FFD300
12: #FFD300
13: #FFD300
14: #FFD300
15: #FFD300
background: #2B2400
foreground: #FFD300
cursorColor: #FFD300

n0tch2k
0: #383838
1: #a95551
2: #666666
3: #a98051
4: #657d3e
5: #767676
6: #c9c9c9
7: #d0b8a3
8: #474747
9: #a97775
10: #8c8c8c
11: #a99175
12: #98bd5e
13: #a3a3a3
14: #dcdcdc
15: #d8c8bb
background: #222222
foreground: #a0a0a0
cursorColor: #a0a0a0

neon-night
0: #20242d
1: #FF8E8E
2: #7EFDD0
3: #FCAD3F
4: #69B4F9
5: #DD92F6
6: #8CE8ff
7: #C9CCCD
8: #20242d
9: #FF8E8E
10: #7EFDD0
11: #FCAD3F
12: #69B4F9
13: #DD92F6
14: #8CE8ff
15: #C9CCCD
background: #20242d
foreground: #C7C8FF
cursorColor: #C7C8FF

neopolitan
0: #000000
1: #800000
2: #61ce3c
3: #fbde2d
4: #253b76
5: #ff0080
6: #8da6ce
7: #f8f8f8
8: #000000
9: #800000
10: #61ce3c
11: #fbde2d
12: #253b76
13: #ff0080
14: #8da6ce
15: #f8f8f8
background: #271f19
foreground: #ffffff
cursorColor: #ffffff

nep
0: #000000
1: #dd6f00
2: #00dd6f
3: #6fdd00
4: #6f00dd
5: #dd006f
6: #006fdd
7: #f2f2f2
8: #7d7d7d
9: #ffb974
10: #74ffb9
11: #b9ff74
12: #b974ff
13: #ff74b9
14: #74b9ff
15: #ffffff
background: #758480
foreground: #23476a
cursorColor: #23476a

neutron
0: #23252b
1: #b54036
2: #5ab977
3: #deb566
4: #6a7c93
5: #a4799d
6: #3f94a8
7: #e6e8ef
8: #23252b
9: #b54036
10: #5ab977
11: #deb566
12: #6a7c93
13: #a4799d
14: #3f94a8
15: #ebedf2
background: #1c1e22
foreground: #e6e8ef
cursorColor: #e6e8ef

nightlion-v1
0: #4c4c4c
1: #bb0000
2: #5fde8f
3: #f3f167
4: #276bd8
5: #bb00bb
6: #00dadf
7: #bbbbbb
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
background: #000000
foreground: #bbbbbb
cursorColor: #bbbbbb

nightlion-v2
0: #4c4c4c
1: #bb0000
2: #04f623
3: #f3f167
4: #64d0f0
5: #ce6fdb
6: #00dadf
7: #bbbbbb
8: #555555
9: #ff5555
10: #7df71d
11: #ffff55
12: #62cbe8
13: #ff9bf5
14: #00ccd8
15: #ffffff
background: #171717
foreground: #bbbbbb
cursorColor: #bbbbbb

nighty
0: #373D48
1: #9B3E46
2: #095B32
3: #808020
4: #1D3E6F
5: #823065
6: #3A7458
7: #828282
8: #5C6370
9: #D0555F
10: #119955
11: #DFE048
12: #4674B8
13: #ED86C9
14: #70D2A4
15: #DFDFDF
background: #2F2F2F
foreground: #DFDFDF
cursorColor: #DFDFDF

nord-light
0: #353535
1: #E64569
2: #89D287
3: #DAB752
4: #439ECF
5: #D961DC
6: #64AAAF
7: #B3B3B3
8: #535353
9: #E4859A
10: #A2CCA1
11: #E1E387
12: #6FBBE2
13: #E586E7
14: #96DCDA
15: #DEDEDE
background: #ebeaf2
foreground: #004f7c

nord
0: #3B4252
1: #BF616A
2: #A3BE8C
3: #EBCB8B
4: #81A1C1
5: #B48EAD
6: #88C0D0
7: #E5E9F0
8: #4C566A
9: #BF616A
10: #A3BE8C
11: #EBCB8B
12: #81A1C1
13: #B48EAD
14: #8FBCBB
15: #ECEFF4
background: #2E3440
foreground: #D8DEE9
cursorColor: #D8DEE9

nord-alt
0: #2E3440
1: #3B4252
2: #434C5E
3: #4C566A
4: #D8DEE9
5: #E5E9F0
6: #ECEFF4
7: #8FBCBB
8: #BF616A
9: #D08770
10: #EBCB8B
11: #A3BE8C
12: #88C0D0
13: #81A1C1
14: #B48EAD
15: #5E81AC
background: #2E3440
foreground: #8FBCBB

novel
0: #000000
1: #cc0000
2: #009600
3: #d06b00
4: #0000cc
5: #cc00cc
6: #0087cc
7: #cccccc
8: #808080
9: #cc0000
10: #009600
11: #d06b00
12: #0000cc
13: #cc00cc
14: #0087cc
15: #ffffff
background: #dfdbc3
foreground: #3b2322
cursorColor: #3b2322

obsidian
0: #000000
1: #a60001
2: #00bb00
3: #fecd22
4: #3a9bdb
5: #bb00bb
6: #00bbbb
7: #bbbbbb
8: #555555
9: #ff0003
10: #93c863
11: #fef874
12: #a1d7ff
13: #ff55ff
14: #55ffff
15: #ffffff
background: #283033
foreground: #cdcdcd
cursorColor: #cdcdcd

ocean-dark
0: #4F4F4F
1: #AF4B57
2: #AFD383
3: #E5C079
4: #7D90A4
5: #A4799D
6: #85A6A5
7: #EEEDEE
8: #7B7B7B
9: #AF4B57
10: #CEFFAB
11: #FFFECC
12: #B5DCFE
13: #FB9BFE
14: #DFDFFD
15: #FEFFFE
background: #1C1F27
foreground: #979CAC
cursorColor: #979CAC

oceanic-next
0: #121C21
1: #E44754
2: #89BD82
3: #F7BD51
4: #5486C0
5: #B77EB8
6: #50A5A4
7: #FFFFFF
8: #52606B
9: #E44754
10: #89BD82
11: #F7BD51
12: #5486C0
13: #B77EB8
14: #50A5A4
15: #FFFFFF
background: #121b21
foreground: #b3b8c3
cursorColor: #b3b8c3

ocean
0: #000000
1: #990000
2: #00a600
3: #999900
4: #0000b2
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
background: #224fbc
foreground: #ffffff
cursorColor: #ffffff

ollie
0: #000000
1: #ac2e31
2: #31ac61
3: #ac4300
4: #2d57ac
5: #b08528
6: #1fa6ac
7: #8a8eac
8: #5b3725
9: #ff3d48
10: #3bff99
11: #ff5e1e
12: #4488ff
13: #ffc21d
14: #1ffaff
15: #5b6ea7
background: #222125
foreground: #8a8dae
cursorColor: #8a8dae

one-dark
0: #000000
1: #E06C75
2: #98C379
3: #D19A66
4: #61AFEF
5: #C678DD
6: #56B6C2
7: #ABB2BF
8: #5C6370
9: #E06C75
10: #98C379
11: #D19A66
12: #61AFEF
13: #C678DD
14: #56B6C2
15: #FFFEFE
background: #1E2127
foreground: #5C6370
cursorColor: #5C6370

one-half-black
0: #282c34
1: #e06c75
2: #98c379
3: #e5c07b
4: #61afef
5: #c678dd
6: #56b6c2
7: #dcdfe4
8: #282c34
9: #e06c75
10: #98c379
11: #e5c07b
12: #61afef
13: #c678dd
14: #56b6c2
15: #dcdfe4
background: #000000
foreground: #dcdfe4
cursorColor: #dcdfe4

one-light
0: #000000
1: #DA3E39
2: #41933E
3: #855504
4: #315EEE
5: #930092
6: #0E6FAD
7: #8E8F96
8: #2A2B32
9: #DA3E39
10: #41933E
11: #855504
12: #315EEE
13: #930092
14: #0E6FAD
15: #FFFEFE
background: #F8F8F8
foreground: #2A2B32
cursorColor: #2A2B32

pali
0: #0a0a0a
1: #ab8f74
2: #74ab8f
3: #8fab74
4: #8f74ab
5: #ab748f
6: #748fab
7: #F2F2F2
8: #5D5D5D
9: #FF1D62
10: #9cc3af
11: #FFD00A
12: #af9cc3
13: #FF1D62
14: #4BB8FD
15: #A020F0
background: #232E37
foreground: #d9e6f2
cursorColor: #d9e6f2

papercolor-dark
0: #1C1C1C
1: #AF005F
2: #5FAF00
3: #D7AF5F
4: #5FAFD7
5: #808080
6: #D7875F
7: #D0D0D0
8: #585858
9: #5FAF5F
10: #AFD700
11: #AF87D7
12: #FFAF00
13: #FF5FAF
14: #00AFAF
15: #5F8787
background: #1C1C1C
foreground: #D0D0D0
cursorColor: #D0D0D0

papercolor-light
0: #EEEEEE
1: #AF0000
2: #008700
3: #5F8700
4: #0087AF
5: #878787
6: #005F87
7: #444444
8: #BCBCBC
9: #D70000
10: #D70087
11: #8700AF
12: #D75F00
13: #D75F00
14: #005FAF
15: #005F87
background: #EEEEEE
foreground: #444444
cursorColor: #444444

paraiso-dark
0: #2f1e2e
1: #ef6155
2: #48b685
3: #fec418
4: #06b6ef
5: #815ba4
6: #5bc4bf
7: #a39e9b
8: #776e71
9: #ef6155
10: #48b685
11: #fec418
12: #06b6ef
13: #815ba4
14: #5bc4bf
15: #e7e9db
background: #2f1e2e
foreground: #a39e9b
cursorColor: #a39e9b

paul-millr
0: #2a2a2a
1: #ff0000
2: #79ff0f
3: #d3bf00
4: #396bd7
5: #b449be
6: #66ccff
7: #bbbbbb
8: #666666
9: #ff0080
10: #66ff66
11: #f3d64e
12: #709aed
13: #db67e6
14: #7adff2
15: #ffffff
background: #000000
foreground: #f2f2f2
cursorColor: #f2f2f2

pencil-dark
0: #212121
1: #c30771
2: #10a778
3: #a89c14
4: #008ec4
5: #523c79
6: #20a5ba
7: #d9d9d9
8: #424242
9: #fb007a
10: #5fd7af
11: #f3e430
12: #20bbfc
13: #6855de
14: #4fb8cc
15: #f1f1f1
background: #212121
foreground: #f1f1f1
cursorColor: #f1f1f1

pencil-light
0: #212121
1: #c30771
2: #10a778
3: #a89c14
4: #008ec4
5: #523c79
6: #20a5ba
7: #d9d9d9
8: #424242
9: #fb007a
10: #5fd7af
11: #f3e430
12: #20bbfc
13: #6855de
14: #4fb8cc
15: #f1f1f1
background: #f1f1f1
foreground: #424242
cursorColor: #424242

peppermint
0: #353535
1: #E64569
2: #89D287
3: #DAB752
4: #439ECF
5: #D961DC
6: #64AAAF
7: #B3B3B3
8: #535353
9: #E4859A
10: #A2CCA1
11: #E1E387
12: #6FBBE2
13: #E586E7
14: #96DCDA
15: #DEDEDE
background: #000000
foreground: #C7C7C7
cursorColor: #BBBBBB

pnevma
0: #2f2e2d
1: #a36666
2: #90a57d
3: #d7af87
4: #7fa5bd
5: #c79ec4
6: #8adbb4
7: #d0d0d0
8: #4a4845
9: #d78787
10: #afbea2
11: #e4c9af
12: #a1bdce
13: #d7beda
14: #b1e7dd
15: #efefef
background: #1c1c1c
foreground: #d0d0d0
cursorColor: #d0d0d0

pro
0: #000000
1: #990000
2: #00a600
3: #999900
4: #2009db
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
background: #000000
foreground: #f2f2f2
cursorColor: #f2f2f2

red-alert
0: #000000
1: #d62e4e
2: #71be6b
3: #beb86b
4: #489bee
5: #e979d7
6: #6bbeb8
7: #d6d6d6
8: #262626
9: #e02553
10: #aff08c
11: #dfddb7
12: #65aaf1
13: #ddb7df
14: #b7dfdd
15: #ffffff
background: #762423
foreground: #ffffff
cursorColor: #ffffff

red-sands
0: #000000
1: #ff3f00
2: #00bb00
3: #e7b000
4: #0072ff
5: #bb00bb
6: #00bbbb
7: #bbbbbb
8: #555555
9: #bb0000
10: #00bb00
11: #e7b000
12: #0072ae
13: #ff55ff
14: #55ffff
15: #ffffff
background: #7a251e
foreground: #d7c9a7
cursorColor: #d7c9a7

rippedcasts
0: #000000
1: #cdaf95
2: #a8ff60
3: #bfbb1f
4: #75a5b0
5: #ff73fd
6: #5a647e
7: #bfbfbf
8: #666666
9: #eecbad
10: #bcee68
11: #e5e500
12: #86bdc9
13: #e500e5
14: #8c9bc4
15: #e5e5e5
background: #2b2b2b
foreground: #ffffff
cursorColor: #ffffff

royal
0: #241f2b
1: #91284c
2: #23801c
3: #b49d27
4: #6580b0
5: #674d96
6: #8aaabe
7: #524966
8: #312d3d
9: #d5356c
10: #2cd946
11: #fde83b
12: #90baf9
13: #a479e3
14: #acd4eb
15: #9e8cbd
background: #100815
foreground: #514968
cursorColor: #514968

sat
0: #000000
1: #dd0007
2: #07dd00
3: #ddd600
4: #0007dd
5: #d600dd
6: #00ddd6
7: #f2f2f2
8: #7d7d7d
9: #ff7478
10: #78ff74
11: #fffa74
12: #7478ff
13: #fa74ff
14: #74fffa
15: #ffffff
background: #758480
foreground: #23476a
cursorColor: #23476a

seafoam-pastel
0: #757575
1: #825d4d
2: #728c62
3: #ada16d
4: #4d7b82
5: #8a7267
6: #729494
7: #e0e0e0
8: #8a8a8a
9: #cf937a
10: #98d9aa
11: #fae79d
12: #7ac3cf
13: #d6b2a1
14: #ade0e0
15: #e0e0e0
background: #243435
foreground: #d4e7d4
cursorColor: #d4e7d4

sea-shells
0: #17384c
1: #d15123
2: #027c9b
3: #fca02f
4: #1e4950
5: #68d4f1
6: #50a3b5
7: #deb88d
8: #434b53
9: #d48678
10: #628d98
11: #fdd39f
12: #1bbcdd
13: #bbe3ee
14: #87acb4
15: #fee4ce
background: #09141b
foreground: #deb88d
cursorColor: #deb88d

seti
0: #323232
1: #c22832
2: #8ec43d
3: #e0c64f
4: #43a5d5
5: #8b57b5
6: #8ec43d
7: #eeeeee
8: #323232
9: #c22832
10: #8ec43d
11: #e0c64f
12: #43a5d5
13: #8b57b5
14: #8ec43d
15: #ffffff
background: #111213
foreground: #cacecd
cursorColor: #cacecd

shaman
0: #012026
1: #b2302d
2: #00a941
3: #5e8baa
4: #449a86
5: #00599d
6: #5d7e19
7: #405555
8: #384451
9: #ff4242
10: #2aea5e
11: #8ed4fd
12: #61d5ba
13: #1298ff
14: #98d028
15: #58fbd6
background: #001015
foreground: #405555
cursorColor: #405555

shel
0: #2c2423
1: #ab2463
2: #6ca323
3: #ab6423
4: #2c64a2
5: #6c24a2
6: #2ca363
7: #918988
8: #918988
9: #f588b9
10: #c2ee86
11: #f5ba86
12: #8fbaec
13: #c288ec
14: #8feeb9
15: #f5eeec
background: #2a201f
foreground: #4882cd
cursorColor: #4882cd

slate
0: #222222
1: #e2a8bf
2: #81d778
3: #c4c9c0
4: #264b49
5: #a481d3
6: #15ab9c
7: #02c5e0
8: #ffffff
9: #ffcdd9
10: #beffa8
11: #d0ccca
12: #7ab0d2
13: #c5a7d9
14: #8cdfe0
15: #e0e0e0
background: #222222
foreground: #35b1d2
cursorColor: #35b1d2

smyck
0: #000000
1: #C75646
2: #8EB33B
3: #D0B03C
4: #72B3CC
5: #C8A0D1
6: #218693
7: #B0B0B0
8: #5D5D5D
9: #E09690
10: #CDEE69
11: #FFE377
12: #9CD9F0
13: #FBB1F9
14: #77DFD8
15: #F7F7F7
background: #242424
foreground: #F7F7F7
cursorColor: #F7F7F7

snazzy
0: #282A36
1: #FF5C57
2: #5AF78E
3: #F3F99D
4: #57C7FF
5: #FF6AC1
6: #9AEDFE
7: #F1F1F0
8: #686868
9: $COLOR_02
10: $COLOR_03
11: $COLOR_04
12: $COLOR_05
13: $COLOR_06
14: $COLOR_07
15: #EFF0EB
background: $COLOR_01
foreground: $COLOR_16
cursorColor: #97979B

soft-server
0: #000000
1: #a2686a
2: #9aa56a
3: #a3906a
4: #6b8fa3
5: #6a71a3
6: #6ba58f
7: #99a3a2
8: #666c6c
9: #dd5c60
10: #bfdf55
11: #deb360
12: #62b1df
13: #606edf
14: #64e39c
15: #d2e0de
background: #242626
foreground: #99a3a2
cursorColor: #99a3a2

solarized-darcula
0: #25292a
1: #f24840
2: #629655
3: #b68800
4: #2075c7
5: #797fd4
6: #15968d
7: #d2d8d9
8: #25292a
9: #f24840
10: #629655
11: #b68800
12: #2075c7
13: #797fd4
14: #15968d
15: #d2d8d9
background: #3d3f41
foreground: #d2d8d9
cursorColor: #d2d8d9

solarized-dark-higher-contrast
0: #002831
1: #d11c24
2: #6cbe6c
3: #a57706
4: #2176c7
5: #c61c6f
6: #259286
7: #eae3cb
8: #006488
9: #f5163b
10: #51ef84
11: #b27e28
12: #178ec8
13: #e24d8e
14: #00b39e
15: #fcf4dc
background: #001e27
foreground: #9cc2c3
cursorColor: #9cc2c3

solarized-dark
0: #073642
1: #DC322F
2: #859900
3: #CF9A6B
4: #268BD2
5: #D33682
6: #2AA198
7: #EEE8D5
8: #657B83
9: #D87979
10: #88CF76
11: #657B83
12: #2699FF
13: #D33682
14: #43B8C3
15: #FDF6E3
background: #002B36
foreground: #839496
cursorColor: #839496

solarized-light
color-1: #073642
0: #DC322F
1: #859900
2: #B58900
3: #268BD2
4: #D33682
5: #2AA198
6: #EEE8D5
7: #002B36
8: #CB4B16
9: #586E75
10: #657B83
11: #839496
12: #6C71C4
13: #93A1A1
14: #FDF6E3
background: #FDF6E3
foreground: #657B83
cursorColor: #657B83

spacedust
0: #6e5346
1: #e35b00
2: #5cab96
3: #e3cd7b
4: #0f548b
5: #e35b00
6: #06afc7
7: #f0f1ce
8: #684c31
9: #ff8a3a
10: #aecab8
11: #ffc878
12: #67a0ce
13: #ff8a3a
14: #83a7b4
15: #fefff1
background: #0a1e24
foreground: #ecf0c1
cursorColor: #ecf0c1

spacegray-eighties-dull
0: #15171c
1: #b24a56
2: #92b477
3: #c6735a
4: #7c8fa5
5: #a5789e
6: #80cdcb
7: #b3b8c3
8: #555555
9: #ec5f67
10: #89e986
11: #fec254
12: #5486c0
13: #bf83c1
14: #58c2c1
15: #ffffff
background: #222222
foreground: #c9c6bc
cursorColor: #c9c6bc

spacegray-eighties
0: #15171c
1: #ec5f67
2: #81a764
3: #fec254
4: #5486c0
5: #bf83c1
6: #57c2c1
7: #efece7
8: #555555
9: #ff6973
10: #93d493
11: #ffd256
12: #4d84d1
13: #ff55ff
14: #83e9e4
15: #ffffff
background: #222222
foreground: #bdbaae
cursorColor: #bdbaae

spacegray
0: #000000
1: #b04b57
2: #87b379
3: #e5c179
4: #7d8fa4
5: #a47996
6: #85a7a5
7: #b3b8c3
8: #000000
9: #b04b57
10: #87b379
11: #e5c179
12: #7d8fa4
13: #a47996
14: #85a7a5
15: #ffffff
background: #20242d
foreground: #b3b8c3
cursorColor: #b3b8c3

spring
0: #000000
1: #ff4d83
2: #1f8c3b
3: #1fc95b
4: #1dd3ee
5: #8959a8
6: #3e999f
7: #ffffff
8: #000000
9: #ff0021
10: #1fc231
11: #d5b807
12: #15a9fd
13: #8959a8
14: #3e999f
15: #ffffff
background: #0a1e24
foreground: #ecf0c1
cursorColor: #ecf0c1

square
0: #050505
1: #e9897c
2: #b6377d
3: #ecebbe
4: #a9cdeb
5: #75507b
6: #c9caec
7: #f2f2f2
8: #141414
9: #f99286
10: #c3f786
11: #fcfbcc
12: #b6defb
13: #ad7fa8
14: #d7d9fc
15: #e2e2e2
background: #0a1e24
foreground: #1a1a1a
cursorColor: #1a1a1a

srcery
0: #1C1B19
1: #FF3128
2: #519F50
3: #FBB829
4: #5573A3
5: #E02C6D
6: #0AAEB3
7: #918175
8: #2D2B28
9: #F75341
10: #98BC37
11: #FED06E
12: #8EB2F7
13: #E35682
14: #53FDE9
15: #FCE8C3
background: #282828
foreground: #ebdbb2
cursorColor: #ebdbb2

sundried
0: #302b2a
1: #a7463d
2: #587744
3: #9d602a
4: #485b98
5: #864651
6: #9c814f
7: #c9c9c9
8: #4d4e48
9: #aa000c
10: #128c21
11: #fc6a21
12: #7999f7
13: #fd8aa1
14: #fad484
15: #ffffff
background: #1a1818
foreground: #c9c9c9
cursorColor: #c9c9c9

symphonic
0: #000000
1: #dc322f
2: #56db3a
3: #ff8400
4: #0084d4
5: #b729d9
6: #ccccff
7: #ffffff
8: #1b1d21
9: #dc322f
10: #56db3a
11: #ff8400
12: #0084d4
13: #b729d9
14: #ccccff
15: #ffffff
background: #000000
foreground: #ffffff
cursorColor: #ffffff

teerb
0: #1c1c1c
1: #d68686
2: #aed686
3: #d7af87
4: #86aed6
5: #d6aed6
6: #8adbb4
7: #d0d0d0
8: #1c1c1c
9: #d68686
10: #aed686
11: #e4c9af
12: #86aed6
13: #d6aed6
14: #b1e7dd
15: #efefef
background: #262626
foreground: #d0d0d0
cursorColor: #d0d0d0

terminal-basic
0: #000000
1: #990000
2: #00a600
3: #999900
4: #0000b2
5: #b200b2
6: #00a6b2
7: #bfbfbf
8: #666666
9: #e50000
10: #00d900
11: #e5e500
12: #0000ff
13: #e500e5
14: #00e5e5
15: #e5e5e5
background: #ffffff
foreground: #000000
cursorColor: #000000

terminix-dark
0: #282a2e
1: #a54242
2: #a1b56c
3: #de935f
4: #225555
5: #85678f
6: #5e8d87
7: #777777
8: #373b41
9: #c63535
10: #608360
11: #fa805a
12: #449da1
13: #ba8baf
14: #86c1b9
15: #c5c8c6
background: #091116
foreground: #868A8C
cursorColor: #868A8C

thayer-bright
0: #1b1d1e
1: #f92672
2: #4df840
3: #f4fd22
4: #2757d6
5: #8c54fe
6: #38c8b5
7: #ccccc6
8: #505354
9: #ff5995
10: #b6e354
11: #feed6c
12: #3f78ff
13: #9e6ffe
14: #23cfd5
15: #f8f8f2
background: #1b1d1e
foreground: #f8f8f8
cursorColor: #f8f8f8

tin
0: #000000
1: #8d534e
2: #4e8d53
3: #888d4e
4: #534e8d
5: #8d4e88
6: #4e888d
7: #ffffff
8: #000000
9: #b57d78
10: #78b57d
11: #b0b578
12: #7d78b5
13: #b578b0
14: #78b0b5
15: #ffffff
background: #2e2e35
foreground: #ffffff
cursorColor: #ffffff

tomorrow-night-blue
0: #000000
1: #FF9DA3
2: #D1F1A9
3: #FFEEAD
4: #BBDAFF
5: #EBBBFF
6: #99FFFF
7: #FFFEFE
8: #000000
9: #FF9CA3
10: #D0F0A8
11: #FFEDAC
12: #BADAFF
13: #EBBAFF
14: #99FFFF
15: #FFFEFE
background: #002451
foreground: #FFFEFE
cursorColor: #FFFEFE

tomorrow-night-bright
0: #000000
1: #D54E53
2: #B9CA49
3: #E7C547
4: #79A6DA
5: #C397D8
6: #70C0B1
7: #FFFEFE
8: #000000
9: #D44D53
10: #B9C949
11: #E6C446
12: #79A6DA
13: #C396D7
14: #70C0B1
15: #FFFEFE
background: #000000
foreground: #E9E9E9
cursorColor: #E9E9E9

tomorrow-night-eighties
0: #000000
1: #F27779
2: #99CC99
3: #FFCC66
4: #6699CC
5: #CC99CC
6: #66CCCC
7: #FFFEFE
8: #000000
9: #F17779
10: #99CC99
11: #FFCC66
12: #6699CC
13: #CC99CC
14: #66CCCC
15: #FFFEFE
background: #2C2C2C
foreground: #CCCCCC
cursorColor: #CCCCCC

tomorrow-night
0: #000000
1: #CC6666
2: #B5BD68
3: #F0C674
4: #81A2BE
5: #B293BB
6: #8ABEB7
7: #FFFEFE
8: #000000
9: #CC6666
10: #B5BD68
11: #F0C574
12: #80A1BD
13: #B294BA
14: #8ABDB6
15: #FFFEFE
background: #1D1F21
foreground: #C5C8C6
cursorColor: #C4C8C5

tomorrow
0: #000000
1: #C82828
2: #718C00
3: #EAB700
4: #4171AE
5: #8959A8
6: #3E999F
7: #FFFEFE
8: #000000
9: #C82828
10: #708B00
11: #E9B600
12: #4170AE
13: #8958A7
14: #3D999F
15: #FFFEFE
background: #FFFFFF
foreground: #4D4D4C
cursorColor: #4C4C4C

toy-chest
0: #2c3f58
1: #be2d26
2: #1a9172
3: #db8e27
4: #325d96
5: #8a5edc
6: #35a08f
7: #23d183
8: #336889
9: #dd5944
10: #31d07b
11: #e7d84b
12: #34a6da
13: #ae6bdc
14: #42c3ae
15: #d5d5d5
background: #24364b
foreground: #31d07b
cursorColor: #31d07b

treehouse
0: #321300
1: #b2270e
2: #44a900
3: #aa820c
4: #58859a
5: #97363d
6: #b25a1e
7: #786b53
8: #433626
9: #ed5d20
10: #55f238
11: #f2b732
12: #85cfed
13: #e14c5a
14: #f07d14
15: #ffc800
background: #191919
foreground: #786b53
cursorColor: #786b53

twilight
0: #141414
1: #c06d44
2: #afb97a
3: #c2a86c
4: #44474a
5: #b4be7c
6: #778385
7: #ffffd4
8: #262626
9: #de7c4c
10: #ccd88c
11: #e2c47e
12: #5a5e62
13: #d0dc8e
14: #8a989b
15: #ffffd4
background: #141414
foreground: #ffffd4
cursorColor: #ffffd4

ura
0: #000000
1: #c21b6f
2: #6fc21b
3: #c26f1b
4: #1b6fc2
5: #6f1bc2
6: #1bc26f
7: #808080
8: #808080
9: #ee84b9
10: #b9ee84
11: #eeb984
12: #84b9ee
13: #b984ee
14: #84eeb9
15: #e5e5e5
background: #feffee
foreground: #23476a
cursorColor: #23476a

urple
0: #000000
1: #b0425b
2: #37a415
3: #ad5c42
4: #564d9b
5: #6c3ca1
6: #808080
7: #87799c
8: #5d3225
9: #ff6388
10: #29e620
11: #f08161
12: #867aed
13: #a05eee
14: #eaeaea
15: #bfa3ff
background: #1b1b23
foreground: #877a9b
cursorColor: #877a9b

vag
0: #303030
1: #a87139
2: #39a871
3: #71a839
4: #7139a8
5: #a83971
6: #3971a8
7: #8a8a8a
8: #494949
9: #b0763b
10: #3bb076
11: #76b03b
12: #763bb0
13: #b03b76
14: #3b76b0
15: #cfcfcf
background: #191f1d
foreground: #d9e6f2
cursorColor: #d9e6f2

vaughn
0: #25234f
1: #705050
2: #60b48a
3: #dfaf8f
4: #5555ff
5: #f08cc3
6: #8cd0d3
7: #709080
8: #709080
9: #dca3a3
10: #60b48a
11: #f0dfaf
12: #5555ff
13: #ec93d3
14: #93e0e3
15: #ffffff
background: #25234f
foreground: #dcdccc
cursorColor: #dcdccc

vibrant-ink
0: #878787
1: #ff6600
2: #ccff04
3: #ffcc00
4: #44b4cc
5: #9933cc
6: #44b4cc
7: #f5f5f5
8: #555555
9: #ff0000
10: #00ff00
11: #ffff00
12: #0000ff
13: #ff00ff
14: #00ffff
15: #e5e5e5
background: #000000
foreground: #ffffff
cursorColor: #ffffff

vs-code-dark-plus
0: #6A787A
1: #E9653B
2: #39E9A8
3: #E5B684
4: #44AAE6
5: #E17599
6: #3DD5E7
7: #C3DDE1
8: #598489
9: #E65029
10: #00FF9A
11: #E89440
12: #009AFB
13: #FF578F
14: #5FFFFF
15: #D9FBFF
background: #1E1E1E
foreground: #CCCCCC
cursorColor: #CCCCCC

warm-neon
0: #000000
1: #e24346
2: #39b13a
3: #dae145
4: #4261c5
5: #f920fb
6: #2abbd4
7: #d0b8a3
8: #fefcfc
9: #e97071
10: #9cc090
11: #ddda7a
12: #7b91d6
13: #f674ba
14: #5ed1e5
15: #d8c8bb
background: #404040
foreground: #afdab6
cursorColor: #afdab6

wez
0: #000000
1: #cc5555
2: #55cc55
3: #cdcd55
4: #5555cc
5: #cc55cc
6: #7acaca
7: #cccccc
8: #555555
9: #ff5555
10: #55ff55
11: #ffff55
12: #5555ff
13: #ff55ff
14: #55ffff
15: #ffffff
background: #000000
foreground: #b3b3b3
cursorColor: #b3b3b3

wild-cherry
0: #000507
1: #d94085
2: #2ab250
3: #ffd16f
4: #883cdc
5: #ececec
6: #c1b8b7
7: #fff8de
8: #009cc9
9: #da6bac
10: #f4dca5
11: #eac066
12: #308cba
13: #ae636b
14: #ff919d
15: #e4838d
background: #1f1726
foreground: #dafaff
cursorColor: #dafaff

wombat
0: #000000
1: #ff615a
2: #b1e969
3: #ebd99c
4: #5da9f6
5: #e86aff
6: #82fff7
7: #dedacf
8: #313131
9: #f58c80
10: #ddf88f
11: #eee5b2
12: #a5c7ff
13: #ddaaff
14: #b7fff9
15: #ffffff
background: #171717
foreground: #dedacf
cursorColor: #dedacf

wryan
0: #333333
1: #8c4665
2: #287373
3: #7c7c99
4: #395573
5: #5e468c
6: #31658c
7: #899ca1
8: #3d3d3d
9: #bf4d80
10: #53a6a6
11: #9e9ecb
12: #477ab3
13: #7e62b3
14: #6096bf
15: #c0c0c0
background: #101010
foreground: #999993
cursorColor: #999993

zenburn
0: #4d4d4d
1: #705050
2: #60b48a
3: #f0dfaf
4: #506070
5: #dc8cc3
6: #8cd0d3
7: #dcdccc
8: #709080
9: #dca3a3
10: #c3bf9f
11: #e0cf9f
12: #94bff3
13: #ec93d3
14: #93e0e3
15: #ffffff
background: #3f3f3f
foreground: #dcdccc
cursorColor: #dcdccc
!
)

# Use truecolor sequences to simulate the end result.
preview() {
	echo "$themes"| awk -F": " -v target="$1" '
		BEGIN {
			"tput cols" | getline nc
			"tput lines" | getline nr
			nc = int(nc)
			nr = int(nr)
		}

		function hextorgb(s) {
			hexchars = "0123456789abcdef"
			s = tolower(s)

			r = (index(hexchars, substr(s, 2, 1))-1)*16+(index(hexchars, substr(s, 3, 1))-1)
			g = (index(hexchars, substr(s, 4, 1))-1)*16+(index(hexchars, substr(s, 5, 1))-1)
			b = (index(hexchars, substr(s, 6, 1))-1)*16+(index(hexchars, substr(s, 7, 1))-1)
		}

		function fgesc(col) {
			hextorgb(col)
			return sprintf("\x1b[38;2;%d;%d;%dm", r, g, b)
		}

		function bgesc(col) {
			hextorgb(col)
			return sprintf("\x1b[48;2;%d;%d;%dm", r, g, b)
		}

		$0 == target {s++}

		s && /^foreground:/ { fg = $2 }
		s && /^background:/ { bg = $2 }
		s && /^[0-9]+:/ { a[$1] = $2 }

		/^ *$/ {s=0}

		function puts(s,   len,   i,   normesc,   filling) {
			normesc = sprintf("\x1b[0m%s%s", fgesc(fg), bgesc(bg))

			len=s
			gsub(/\033\[[^m]*m/, "", len)
			len=length(len)

			filling=""
			for(i=0;i<(nc-len);i++) filling=filling" "

			printf "%s%s%s%s\n", normesc, s, normesc, filling, ""
			nr--
		}

		END {
			puts("")
			for (i = 0;i<16;i++)
				puts(sprintf("  %s Color %d\x1b[0m", fgesc(a[i]), i))

			# Note: Some terminals use different colors for bolded text and may produce slightly different ls output.

			puts("")
			puts(" # ls --color -l")
			puts("    total 4")
			puts("    -rw-r--r-- 1 user user    0 Jan  0 02:39 file")
			puts(sprintf("    drwxr-xr-x 2 user user 4096 Jan  0 02:39 \x1b[1m%sdir/", fgesc(a[4])))
			puts(sprintf("    -rwxr-xr-x 1 user user    0 Jan  0 02:39 \x1b[1m%sexecutable", fgesc(a[10])))
			puts(sprintf("    lrwxrwxrwx 1 user user   15 Jan  0 02:40 \x1b[1m%ssymlink\x1b[0m%s%s -> /etc/symlink", fgesc(a[6]), fgesc(fg), bgesc(bg)))


			while(nr > 0) puts("")

			printf "\x1b[0m"
		}
	'
}

preview2() {
	printf '\033[30mColor 0\n'
	printf '\033[31mColor 1\n'
	printf '\033[32mColor 2\n'
	printf '\033[33mColor 3\n'
	printf '\033[34mColor 4\n'
	printf '\033[35mColor 5\n'
	printf '\033[36mColor 6\n'
	printf '\033[37mColor 7\n'

	printf '\033[90mColor 8\n'
	printf '\033[91mColor 9\n'
	printf '\033[92mColor 10\n'
	printf '\033[93mColor 11\n'
	printf '\033[94mColor 12\n'
	printf '\033[95mColor 13\n'
	printf '\033[96mColor 14\n'
	printf '\033[97mColor 15\n'

	printf '\n\033[0m'
	printf '# ls --color -lF\n'
	printf '    total 4\n'
	printf '    -rw-r--r-- 1 user user    0 Jan  0 02:39 file\n'
	printf '    drwxr-xr-x 2 user user 4096 Jan  0 02:39 \033[01;34mdir/\033[0m\n'
	printf '    -rwxr-xr-x 1 user user    0 Jan  0 02:39 \033[01;32mexecutable\033[0m*\n'
	printf '    lrwxrwxrwx 1 user user   15 Jan  0 02:40 \033[01;36msymlink\033[0m -> /etc/symlink\n'

	printf '\033[0m'
}

apply() {
	echo "$themes"| awk -F": " -v target="$1" '
		function tmuxesc(s) { return sprintf("\033Ptmux;\033%s\033\\", s) }
		function normalize_term() {
			# Term detection voodoo

			if(ENVIRON["TERM_PROGRAM"] == "iTerm.app")
				term="iterm"
			else if(ENVIRON["TMUX"]) {
				"tmux display-message -p \"#{client_termname}\"" | getline term
				is_tmux++
			} else
				term=ENVIRON["TERM"]
		}

		BEGIN {
			normalize_term()

			if(term == "iterm") {
				bgesc="\033]Ph%s\033\\"
				fgesc="\033]Pg%s\033\\"
				colesc="\033]P%x%s\033\\"
				curesc="\033]Pl%s\033\\"
			} else if(term ~ /st-.*/) {
				fgesc="\033]4;7;#%s\007"
				bgesc="\033]4;0;#%s\007"
				colesc="\033]4;%d;#%s\007"
				curesc="\033]4;256;#%s\007"
			} else {
				#Terms that play nice :)

				fgesc="\033]10;#%s\007"
				bgesc="\033]11;#%s\007"
				curesc="\033]12;#%s\007"
				colesc="\033]4;%d;#%s\007"
			}

			if(is_tmux) {
				fgesc=tmuxesc(fgesc)
				bgesc=tmuxesc(bgesc)
				curesc=tmuxesc(curesc)
				colesc=tmuxesc(colesc)
			}
		}

		$0 == target {s++}

		s && /^foreground:/ { printf fgesc, substr($2,2) > "/dev/tty" }
		s && /^background:/ { printf bgesc, substr($2,2) > "/dev/tty" }
		s && /^[0-9]+:/ { printf colesc, $1, substr($2,2) > "/dev/tty" }
		s && /^cursorColor+:/ { printf curesc, substr($2,2) > "/dev/tty" }

		s && /^ *$/ {s = 0}
	'
}

if [ -z "$1" ]; then
	echo "Usage: $(basename "$0") [-l|--list] [-i|--interactive] [-i2|--interactive2] [-r|--random] <theme>"
	exit
fi

case "$1" in
-i2|--interactive2)
	command -v fzf 2> /dev/null || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	"$0" -l|fzf\
		--bind "enter:execute($0 {})"\
		--bind "down:down+execute-silent($0 {} &)"\
		--bind "up:up+execute-silent($0 {} &)"\
		--bind "change:execute-silent($0 {} &)"\
		--preview "$0 --preview2"
	;;
-r|--random)
	theme=$($0 -l|sort -R|head -n1)
	$0 "$theme"
	echo "Theme: $theme"
	;;
-i|--interactive)
	command -v fzf 2> /dev/null || { echo "ERROR: -i requires fzf" >&2; exit 1; }
	if [ -z "$COLORTERM" ]; then
		echo "This does not appear to be a truecolor terminal, try -i2 instead or set COLORTERM if your terminal has truecolor support."
		exit 1
	else
		"$0" -l|fzf\
			--bind "enter:execute-silent($0 {})"\
			--preview "$0 --preview {}"
	fi
	;;
-l|--list)
	echo "$themes"| awk '/^ *$/ {i=0;next} !i {i=1;print}'
	;;
--preview2)
	preview2 "$2"
	;;
--preview)
	preview "$2"
	;;
*)
	apply "$1"
	;;
esac
