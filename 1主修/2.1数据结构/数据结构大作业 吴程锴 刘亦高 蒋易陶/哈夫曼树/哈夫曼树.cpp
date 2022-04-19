#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//typedef int ELEMTYPE;// 

// 哈夫曼树结点结构体
typedef struct HuffmanTree
{
	int weight;
	int id;        // id用来主要用以区分权值相同的结点
	struct HuffmanTree* lchild;
	struct HuffmanTree* rchild;
}HuffmanNode;

// 构建哈夫曼树
HuffmanNode* createHuffmanTree(int* a, int n)
{
	int i, j;
	HuffmanNode **temp, *hufmTree;
	temp = (HuffmanNode**)malloc(n * sizeof(HuffmanNode));
	for (i = 0; i < n; ++i)     // 将数组a中的权值赋给结点中的weight
	{
		temp[i] = (HuffmanNode*)malloc(sizeof(HuffmanNode));
		temp[i]->weight = a[i];
		temp[i]->id = i;
		temp[i]->lchild = temp[i]->rchild = NULL;
	}
	for (i = 0; i < n - 1; ++i)       // 构建哈夫曼树需要n-1合并
	{
		int small1 = -1, small2;      // small1、small2分别作为最小和次小权值的下标
		for (j = 0; j < n; ++j)         // 先将最小的两个下标赋给small1、small2
		{
			if (temp[j] != NULL && small1 == -1)
			{
				small1 = j;
				continue;
			}
			else if (temp[j] != NULL)
			{
				small2 = j;
				break;
			}
		}

		for (j = small2; j < n; ++j)
		{
			if (temp[j] != NULL)
			{
				if (temp[j]->weight < temp[small1]->weight)  // 比较权值，挪动small1和small2使之分别成为最小和次小权值的下标
				{
					small2 = small1;
					small1 = j;
				}
				else if (temp[j]->weight < temp[small2]->weight)  // 比较权值，挪动small1和small2使之分别成为最小和次小权值的下标
				{
					small2 = j;
				}
			}
		}
		hufmTree = (HuffmanNode*)malloc(sizeof(HuffmanNode));
		hufmTree->weight = temp[small1]->weight + temp[small2]->weight;
		hufmTree->lchild = temp[small1];
		hufmTree->rchild = temp[small2];

		temp[small1] = hufmTree;
		temp[small2] = NULL;
	}
	free(temp);
	return hufmTree;
}

// 以广义表的形式打印哈夫曼树
void PrintHuffmanTree(HuffmanNode* hufmTree)
{
	if (hufmTree)
	{
		printf("%d", hufmTree->weight);
		if (hufmTree->lchild != NULL || hufmTree->rchild != NULL)
		{
			printf("(");
			PrintHuffmanTree(hufmTree->lchild);
			printf(",");
			PrintHuffmanTree(hufmTree->rchild);
			printf(")");
		}
	}
} 


// 递归进行哈夫曼编码
void HuffmanCode(HuffmanNode* hufmTree, int depth,char string[])      // depth为哈夫曼树的深度
{
	static int code[10];
	if (hufmTree)
	{
		if (hufmTree->lchild == NULL && hufmTree->rchild == NULL)
		{
			printf("%c的哈夫曼编码为： ",string[hufmTree->id]);
			int i;
			for (i = 0; i < depth; ++i)
			{
				printf("%d", code[i]);
			}
			printf("\n");
		}
		else
		{
			code[depth] = 0;
			HuffmanCode(hufmTree->lchild, depth + 1,string);
			code[depth] = 1;
			HuffmanCode(hufmTree->rchild, depth + 1,string);
		}
	}
}

//哈夫曼编码
void Encode(HuffmanNode* hufmTree, int depth, int w)
{
	static int num[10];
	if (hufmTree)
	{
		if (hufmTree->lchild == NULL && hufmTree->rchild == NULL && hufmTree->weight == w)
		{
			int i;
			for (i = 0; i < depth; ++i)
			{
				printf("%d", num[i]);
			}
		}
		else
		{
			num[depth] = 0;
			Encode(hufmTree->lchild, depth + 1, w);
			num[depth] = 1;
			Encode(hufmTree->rchild, depth + 1, w);
		}
	}
}

void HuffmanEncode(HuffmanNode* hufmTree, char string[], char ch[], int* a)
{
	int i, j;
	for (i = 0; i < strlen(string); i++)
	{
		for (j = 0; j < strlen(ch); j++)
		{
			if (string[i] == ch[j])
			{
				Encode(hufmTree, 0, a[j]);
			}
		}
	}
	
}

// 哈夫曼解码
void HuffmanDecode(char ch[], HuffmanNode* hufmTree, char string[])     // ch是要解码的01串，string是结点对应的字符
{
	int i;
	int num[100];
	HuffmanNode* tempTree = NULL;
	for (i = 0; i < strlen(ch); ++i)
	{
		if (ch[i] == '0')
			num[i] = 0;
		else
			num[i] = 1;
	}
	if (hufmTree)
	{
		i = 0;
		while (i < strlen(ch))
		{
			tempTree = hufmTree;
			while (tempTree->lchild != NULL && tempTree->rchild != NULL)
			{
				if (num[i] == 0)
				{
					tempTree = tempTree->lchild;
				}
				else
				{
					tempTree = tempTree->rchild;
				}
				i++;
			}
			printf("%c", string[tempTree->id]);     // 输出解码后对应结点的字符
		}
	}
}

//主程序
int main()
{
	printf("创建哈夫曼树:");
	int i, n;
	printf("请输入字符的个数：\n");
	while (1)
	{
		scanf("%d", &n);
		if (n > 1)
			break;
		else
			printf("输入错误，请重新输入！");
	}

	int* arr;
	arr = (int*)malloc(n * sizeof(int));
	printf("请输入%d个字符出现的频度：\n", n);
	for (i = 0; i < n; ++i)
	{
		scanf("%d", &arr[i]);
	}

	char ch[100], string[100],c;
	printf("请连续输入这%d个频度各自所代表的字符：\n", n);
	fflush(stdin);      // 强行清除缓存中的数据，也就是上面输入权值结束时的回车符
	gets(string);

	HuffmanNode* hufmTree = NULL;
	hufmTree = createHuffmanTree(arr, n);

	printf("此哈夫曼树的广义表形式为：\n");
	PrintHuffmanTree(hufmTree);

	printf("\n各字符的哈夫曼编码为：\n");
	HuffmanCode(hufmTree, 0, string);

	printf("\ne:编码(Encode)\nd:解码(Decode)\nq:退出(Quit))\n");
	printf("请选择操作：");
	scanf("%c",&c);
	printf("\n");
	do
	{
		switch (c)
		{
			case'e':
			{
				printf("请输入想要编码的文本：");
				fflush(stdin); 
				gets(ch);
				printf("编码结果为：\n");
				HuffmanEncode(hufmTree, ch, string, arr);
				printf("\n");
				printf("\ne:编码(Encode)\nd:解码(Decode)\nq:退出(Quit))\n");
				printf("请选择操作：");
				break;
			}
			case'd':
			{
				printf("请输入想要解码的电文：");
				fflush(stdin); 
				gets(ch);
				printf("解码结果为：\n");
				HuffmanDecode(ch, hufmTree, string);
				printf("\n");
				printf("\ne:编码(Encode)\nd:解码(Decode)\nq:退出(Quit))\n");
				printf("请选择操作：");
				break;
			}
			case'q':
			{
				exit(0);
				break;
			}
			default:
			{
				exit(0);
				break;
			}
		}
		scanf("%c",&c);
	} while (c != 'q');
	
	free(arr);
	free(hufmTree);

	return 0;
}
