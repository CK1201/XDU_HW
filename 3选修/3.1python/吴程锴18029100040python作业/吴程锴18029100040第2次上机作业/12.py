from wordcloud import WordCloud
import PIL.Image as image
import numpy

with open("关于实施乡村振兴战略的意见.txt",encoding='utf-8') as fp:
    text = fp.read()
    mask = numpy.array(image.open("fivestart.png"))
    wordcloud = WordCloud(mask = mask).generate(text)
    image_produce = wordcloud.to_image()
    image_produce.show()