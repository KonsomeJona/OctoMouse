from PIL import Image, ImageDraw
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import LinearSegmentedColormap
import xml.etree.ElementTree as ET


class Keyboard:
    def __init__(self):
        self.key_code = {  # gap is width:40, height:
            10: (0, 0, 0, 0), 52: (0, 0, 0, 0), 54: (0, 0, 0, 0), 66: (0, 0, 0, 0), 68: (0, 0, 0, 0),
            70: (0, 0, 0, 0), 77: (0, 0, 0, 0), 93: (0, 0, 0, 0), 94: (0, 0, 0, 0), 95: (0, 0, 0, 0),
            102: (0, 0, 0, 0), 104: (0, 0, 0, 0), 108: (0, 0, 0, 0), 110: (0, 0, 0, 0),
            112: (0, 0, 0, 0), 127: (0, 0, 0, 0),
            0: (442, 550, 80, 80),  # "a", (x, y, width, height)
            1: (562, 550, 80, 80),  # "s", (x, y, width, height)
            2: (682, 550, 80, 80),  # "d", (x, y, width, height)
            3: (802, 550, 80, 80),  # "f", (x, y, width, height)
            4: (922, 550, 80, 80),  # "h", (x, y, width, height)
            5: (1042, 550, 80, 80),  # "g", (x, y, width, height)
            6: (512, 655, 80, 80),  # "z", (x, y, width, height)
            7: (632, 655, 80, 80),  # "x", (x, y, width, height)
            8: (752, 655, 80, 80),  # "c", (x, y, width, height)
            9: (872, 655, 80, 80),  # "v", (x, y, width, height)
            11: (992, 655, 80, 80),  # "b", (x, y, width, height)
            12: (432, 450, 80, 80),  # "q", (x, y, width, height)
            13: (537, 450, 80, 80),  # "w", (x, y, width, height)
            14: (652, 450, 80, 80),  # "e", (x, y, width, height)
            15: (770, 450, 80, 80),  # "r", (x, y, width, height)
            16: (1010, 450, 80, 80),  # "y", (x, y, width, height)
            17: (890, 450, 80, 80),  # "t", (x, y, width, height)
            18: (384, 348, 80, 80),  # "1", (x, y, width, height)
            19: (500, 348, 80, 80),  # "2", (x, y, width, height)
            20: (616, 348, 80, 80),  # "3", (x, y, width, height)
            21: (732, 348, 80, 80),  # "4", (x, y, width, height)
            22: (970, 348, 80, 80),  # "6", (x, y, width, height)
            23: (850, 348, 80, 80),  # "5", (x, y, width, height)
            24: (1680, 348, 80, 80),  # "=", (x, y, width, height)
            25: (1326, 348, 80, 80),  # "9", (x, y, width, height)
            26: (1090, 348, 80, 80),  # "7", (x, y, width, height)
            27: (1560, 348, 80, 80),  # "-", (x, y, width, height)
            28: (1206, 348, 80, 80),  # "8", (x, y, width, height)
            29: (1440, 348, 80, 80),  # "0", (x, y, width, height)
            30: (1716, 450, 80, 80),  # "]", (x, y, width, height)
            31: (1363, 450, 80, 80),  # "o", (x, y, width, height)
            32: (1127, 450, 80, 80),  # "u", (x, y, width, height)
            33: (1596, 450, 80, 80),  # "[", (x, y, width, height)
            34: (1242, 450, 80, 80),  # "i", (x, y, width, height)
            35: (1478, 450, 80, 80),  # "p", (x, y, width, height)
            37: (1406, 550, 80, 80),  # "l", (x, y, width, height)
            38: (1162, 550, 80, 80),  # "j", (x, y, width, height)
            39: (1644, 550, 80, 80),  # "\"", (x, y, width, height)
            40: (1282, 550, 80, 80),  # "k", (x, y, width, height)
            41: (1522, 550, 80, 80),  # ";", (x, y, width, height)
            42: (1826, 450, 80, 80),  # "\\", (x, y, width, height)
            43: (1352, 655, 80, 80),  # ",", (x, y, width, height)
            44: (1588, 655, 80, 80),  # "/", (x, y, width, height)
            45: (1112, 655, 80, 80),  # "n", (x, y, width, height)
            46: (1232, 655, 80, 80),  # "m", (x, y, width, height)
            47: (1472, 655, 80, 80),  # ".", (x, y, width, height)
            50: (265, 348, 80, 80),  # "`", (x, y, width, height)
            65: (0, 0, 80, 80),  # "<keypad-decimal>", (x, y, width, height)
            67: (0, 0, 80, 80),  # "<keypad-multiply>", (x, y, width, height)
            69: (0, 0, 80, 80),  # "<keypad-plus>", (x, y, width, height)
            71: (0, 0, 80, 80),  # "<keypad-clear>", (x, y, width, height)
            75: (0, 0, 80, 80),  # "<keypad-divide>", (x, y, width, height)
            76: (0, 0, 80, 80),  # "<keypad-enter>", (x, y, width, height)
            78: (0, 0, 80, 80),  # "<keypad-minus>", (x, y, width, height)
            81: (0, 0, 80, 80),  # "<keypad-equals>", (x, y, width, height)
            82: (0, 0, 80, 80),  # "<keypad-0>", (x, y, width, height)
            83: (0, 0, 80, 80),  # "<keypad-1>", (x, y, width, height)
            84: (0, 0, 80, 80),  # "<keypad-2>", (x, y, width, height)
            85: (0, 0, 80, 80),  # "<keypad-3>", (x, y, width, height)
            86: (0, 0, 80, 80),  # "<keypad-4>", (x, y, width, height)
            87: (0, 0, 80, 80),  # "<keypad-5>", (x, y, width, height)
            88: (0, 0, 80, 80),  # "<keypad-6>", (x, y, width, height)
            89: (0, 0, 80, 80),  # "<keypad-7>", (x, y, width, height)
            91: (0, 0, 80, 80),  # "<keypad-8>", (x, y, width, height)
            92: (0, 0, 80, 80),  # "<keypad-9>", (x, y, width, height)
            36: (1804, 550, 160, 80),  # "<return>", (x, y, width, height)
            48: (290, 450, 135, 80),  # "<tab>", (x, y, width, height)
            49: (990, 770, 580, 100),  # "<space>", (x, y, width, height)
            51: (1810, 348, 130, 80),  # "<delete>", (x, y, width, height)
            53: (266, 250, 92, 60),  # "<escape>", (x, y, width, height)
            55: (0, 0, 80, 80),  # "<command>", (x, y, width, height)
            56: (330, 655, 220, 80),  # "<shift>", (x, y, width, height)
            57: (300, 550, 160, 80),  # "<capslock>", (x, y, width, height)
            58: (0, 0, 80, 80),  # "<option>", (x, y, width, height)
            59: (0, 0, 80, 80),  # "<control>", (x, y, width, height)
            60: (1762, 655, 220, 80),  # "<right-shift>", (x, y, width, height)
            61: (0, 0, 80, 80),  # "<right-option>", (x, y, width, height)
            62: (0, 0, 80, 80),  # "<right-control>", (x, y, width, height)
            63: (0, 0, 80, 80),  # "<function>", (x, y, width, height)
            64: (0, 0, 80, 80),  # "<f17>", (x, y, width, height)
            72: (0, 0, 80, 80),  # "<volume-up>", (x, y, width, height)
            73: (0, 0, 80, 80),  # "<volume-down>", (x, y, width, height)
            74: (0, 0, 80, 80),  # "<mute>", (x, y, width, height)
            79: (0, 0, 80, 80),  # "<f18>", (x, y, width, height)
            80: (0, 0, 80, 80),  # "<f19>", (x, y, width, height)
            90: (0, 0, 80, 80),  # "<f20>", (x, y, width, height)
            96: (866, 250, 92, 60),  # "<f5>", (x, y, width, height)
            97: (986, 250, 92, 60),  # "<f6>", (x, y, width, height)
            98: (1106, 250, 92, 60),  # "<f7>", (x, y, width, height)
            99: (626, 250, 92, 60),  # "<f3>", (x, y, width, height)
            100: (1230, 250, 92, 60),  # "<f8>", (x, y, width, height)
            101: (1350, 250, 92, 60),  # "<f9>", (x, y, width, height)
            103: (1590, 250, 92, 60),  # "<f11>", (x, y, width, height)
            105: (0, 0, 80, 80),  # "<f13>", (x, y, width, height)
            106: (0, 0, 80, 80),  # "<f16>", (x, y, width, height)
            107: (0, 0, 80, 80),  # "<f14>", (x, y, width, height)
            109: (1470, 250, 92, 60),  # "<f10>", (x, y, width, height)
            111: (1710, 250, 92, 60),  # "<f12>", (x, y, width, height)
            113: (0, 0, 80, 80),  # "<f15>", (x, y, width, height)
            114: (0, 0, 80, 80),  # "<help>", (x, y, width, height)
            115: (0, 0, 80, 80),  # "<home>", (x, y, width, height)
            116: (0, 0, 80, 80),  # "<pageup>", (x, y, width, height)
            117: (0, 0, 80, 80),  # "<forward-delete>", (x, y, width, height)
            118: (746, 250, 92, 60),  # "<f4>", (x, y, width, height)
            119: (0, 0, 80, 80),  # "<end>", (x, y, width, height)
            120: (506, 250, 92, 60),  # "<f2>", (x, y, width, height)
            121: (0, 0, 80, 80),  # "<page-down>", (x, y, width, height)
            122: (386, 250, 92, 60),  # "<f1>", (x, y, width, height)
            123: (1605, 790, 90, 50),  # "<left>", (x, y, width, height)
            124: (1825, 790, 90, 50),  # "<right>", (x, y, width, height)
            125: (1715, 790, 90, 50),  # "<down>", (x, y, width, height)
            126: (1715, 740, 90, 50),  # "<up>", (x, y, width, height)
        }


def _cmap_from_image_path(img_path):
    img = Image.open(img_path)
    # img = img.resize((256, img.height))
    colours = (img.getpixel((x, 0)) for x in range(256))
    colours = [(r / 255, g / 255, b / 255, a / 255) for (r, g, b, a) in colours]
    return LinearSegmentedColormap.from_list('list', colours)


def _colourised(img):
    """ maps values in greyscale image to colours """
    arr = np.array(img)
    rgba_img = _cmap_from_image_path('/Users/orange/PycharmProjects/keyboardheatmap.py/default.png')(arr, bytes=True)
    return Image.fromarray(rgba_img, mode="RGBA")


def heatmap(width, height, points):
    heat = Image.new('RGBA', (width, height), color=255)

    dot = (Image.open('450pxdot.png').convert(mode='L').copy()
           .resize((1, 1), resample=Image.ANTIALIAS))
    print(np.array(dot))
    # dot = _img_to_opacity(dot, self.point_strength)

    for x, y in points:
        x, y = int(x - 50 / 2), int(y - 50 / 2)
        heat.paste(dot, (x, y), dot)

    return heat


# [key_code, count]
def draw_heat(width, height, points):
    dot_img = Image.open('450pxdot.png').resize((80, 80), resample=Image.ANTIALIAS).convert('LA')

    kb = Keyboard()
    max_count = max([c[1] for c in points])
    _colors = LinearSegmentedColormap.from_list('kb', (
        (0, '#ffffff'),
        (0.0000000000001, '#FFFFE0'),
        (0.01, '#FFEEEE'),
        # (0.333, '#FF6600'),
        # (0.667, '#FF3300'),
        (0.5, '#FF7777'),
        (1, '#FF0000'),
    ))

    img = Image.new('RGBA', (width, height), color=255)
    print(np.array(img)[..., :3].shape)
    draw = ImageDraw.Draw(img)
    for code, count in points:
        if count == 0:
            continue

        (x, y, w, h) = kb.key_code[code]
        c = _colors(count / max_count)
        r = int(c[0] * 255)
        g = int(c[1] * 255)
        b = int(c[2] * 255)
        if count == 0:
            a = 0
        else:
            a = int(33 if (count / max_count < 0.01) else 150 - (1 - count / max_count) * 20)

        draw.rectangle([(x - w / 2, y - h / 2), (x + w / 2, y + h / 2)], fill=(r, g, b, a))

    return img


def draw_heat2(width, height, points):
    kb = Keyboard()
    max_count = max([c[1] for c in points])
    _colors = LinearSegmentedColormap.from_list('kb', (
        (0, '#ffffff'),
        (0.0000000000001, '#FFFFE0'),
        (0.01, '#FFEEEE'),
        (0.5, '#FF7777'),
        (1, '#FF0000'),
    ))

    # img = Image.new('RGBA', (width, height), color=255).copy()
    img_arr = np.zeros((height, width, 4))
    img_arr[..., 3] = 150

    draw = ImageDraw.Draw(img)
    # for code, count in points:
    for code, count in points:
        (x, y, w, h) = kb.key_code[code]
        # (x, y, w, h) = (5, 5, 5, 5)

        if w == 0 or h == 0 or x == 0 or y == 0:
            continue

        dot = np.zeros((h, w), np.float32)
        d_vertical = 2.0/h
        d_horizontal = 2.0/w
        for i in range(h):
            dot[i, :] = [max(1 - abs((h-1)*0.5-i) * d_vertical - abs((w-1)*0.5 - j) * d_horizontal, 0) for j in range(w)]

        color = _colors(count/max_count)
        to_add = np.zeros((*dot.shape, 3))
        to_add[..., 0] = color[0]#  * dot
        to_add[..., 1] = color[1]#  * dot
        to_add[..., 2] = color[2]#  * dot
        to_add *= 255

        # img_arr[int(y-h/2):int(y+h/2), int(x-w/2):int(x+w/2), 0] += color[0] * dot
        # img_arr[int(y-h/2):int(y+h/2), int(x-w/2):int(x+w/2), 1] += color[1] * dot
        # img_arr[int(y-h/2):int(y+h/2), int(x-w/2):int(x+w/2), 2] += color[2] * dot
        # img_arr[int(y-h/2):int(y+h/2), int(x-w/2):int(x+w/2), :3] += color[..., :3]
        img_arr[int(y-h/2):int(y+h/2), int(x-w/2):int(x+w/2), :3] += to_add[..., :]

    squeeze_img_arr = img_arr[..., :3].sum(axis=2)
    img_arr[squeeze_img_arr == 0, 3] = 0
    return Image.fromarray(np.uint8(img_arr))


if __name__ == '__main__':
    # load keyboard hit file
    tree = ET.parse('/Users/orange/tmp/1.xml')

    index = -1
    for k, v in enumerate(tree.getroot()[0]):
        if v.text == 'global':
            index = k+1
    key_array = tree.getroot()[0][index].find('array')
    for i, v in enumerate(key_array):
        print(i, v.text)
    points = [(i, int(v.text)) for i, v in enumerate(key_array)]

    img = Image.open('keyboard.jpeg')
    width, height = img.size
    hm = draw_heat2(width, height, points)
    # hm = draw_heat(width, height, [(x, random.randint(0, 50)) for x in range(128)])

    img = Image.alpha_composite(img.convert('RGBA'), hm)
    plt.imshow(img)
    plt.show()
    plt.imsave('output.png', img)
