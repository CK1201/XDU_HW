import torch
import torch.nn as nn
import torch.utils.data as Data
from torch.autograd import Variable
import torchvision
from torchvision import transforms
from torchvision.datasets import ImageFolder
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np

LR=0.001
EPOCH=10
train=0

Dog_names=['哈士奇','柯基犬','秋田犬','边境牧羊犬']
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
size=256
data_transform = transforms.Compose([
    transforms.Resize(size),
    transforms.CenterCrop((size, size)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.5,0.5,0.5],
        std=[0.5, 0.5, 0.5])
])
train_dataset = ImageFolder("DogData/",transform = data_transform)
train_loader = Data.DataLoader(dataset=train_dataset, batch_size=10, shuffle=True, num_workers=2)
img, label = train_dataset.__getitem__(600)

# unloader = torchvision.transforms.ToPILImage()  # .ToPILImage() 把tensor或数组转换成图像
# def imshow(tensor, title=None):
#     image = tensor.cpu().clone()    # we clone the tensor to not do changes on it
#     image = image.squeeze(0)
#
#     image = unloader(image)         # tensor转换成图像
#     plt.imshow(image)
#     if title is not None:
#         plt.title(title)
#     plt.pause(1)                    # 只是延迟显示作用
#
# plt.figure()
# imshow(img, title='Image')

class CNN(nn.Module):
    def __init__(self):
        super(CNN,self).__init__()
        self.conv1 = nn.Sequential(
            nn.Conv2d(          #3*256*256
                in_channels=3,
                out_channels=16,
                kernel_size=5,
                stride=1,
                padding=2
            ),                  #16*256*256
            nn.ReLU(),          #16*256*256
            nn.MaxPool2d(kernel_size=2)#16*128*128
        )
        self.conv2 = nn.Sequential(#16*128*128
            nn.Conv2d(
                in_channels=16,
                out_channels=32,
                kernel_size=5,
                stride=1,
                padding=2
            ),                      #32*128*128
            nn.ReLU(),              #32*128*128
            nn.MaxPool2d(kernel_size=2)#32*64*64
        )
        self.out = nn.Linear(32*64*64,4)

    def forward(self,x):
        x = self.conv1(x)
        x = self.conv2(x)
        x = x.view(x.size(0),-1)
        output = self.out(x)
        return output
if __name__ == '__main__':
    cnn = CNN()
    if train==1:
        optimizer = torch.optim.Adam(cnn.parameters(),lr=LR)
        loss_func = nn.CrossEntropyLoss()
        cnn=cnn.to(device)

        for epoch in range(EPOCH):
            for step, (x,y) in enumerate(train_loader):
                x = x.to(device)
                y = y.to(device)
                b_x = Variable(x)
                b_y = Variable(y)

                output = cnn(b_x)
                loss = loss_func(output, b_y)
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()
                print('loss:',float(loss.data))
        torch.save(cnn.state_dict(), 'CNN.pth')


    cnn.load_state_dict(torch.load('CNN.pth'))

    image1 = Image.open('DogData/哈士奇/15_15_N_15_哈士奇69.jpg')
    image2 = Image.open('DogData/柯基犬/2_2_N_2_柯基犬21.jpg')
    image3 = Image.open('DogData/秋田犬/13_13_N_13_秋田犬20.jpg')
    image4 = Image.open('DogData/边境牧羊犬/10_10_N_10_边境牧羊犬20.jpg')

    image = image1
    image_transformed = data_transform(image)
    image_transformed = image_transformed.unsqueeze(0)
    image_transformed = Variable(image_transformed)
    output = cnn(image_transformed)

    predict_value, predict_idx = torch.max(output, 1)
    print('image1预测结果:',Dog_names[predict_idx])

    image = image2
    image_transformed = data_transform(image)
    image_transformed = image_transformed.unsqueeze(0)
    image_transformed = Variable(image_transformed)
    output = cnn(image_transformed)

    predict_value, predict_idx = torch.max(output, 1)
    print('image1预测结果:', Dog_names[predict_idx])

    image = image3
    image_transformed = data_transform(image)
    image_transformed = image_transformed.unsqueeze(0)
    image_transformed = Variable(image_transformed)
    output = cnn(image_transformed)

    predict_value, predict_idx = torch.max(output, 1)
    print('image1预测结果:', Dog_names[predict_idx])

    image = image4
    image_transformed = data_transform(image)
    image_transformed = image_transformed.unsqueeze(0)
    image_transformed = Variable(image_transformed)
    output = cnn(image_transformed)

    predict_value, predict_idx = torch.max(output, 1)
    print('image1预测结果:', Dog_names[predict_idx])
