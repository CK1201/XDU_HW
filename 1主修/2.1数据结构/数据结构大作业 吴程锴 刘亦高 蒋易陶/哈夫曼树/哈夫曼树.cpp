#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//typedef int ELEMTYPE;// 

// �����������ṹ��
typedef struct HuffmanTree
{
	int weight;
	int id;        // id������Ҫ��������Ȩֵ��ͬ�Ľ��
	struct HuffmanTree* lchild;
	struct HuffmanTree* rchild;
}HuffmanNode;

// ������������
HuffmanNode* createHuffmanTree(int* a, int n)
{
	int i, j;
	HuffmanNode **temp, *hufmTree;
	temp = (HuffmanNode**)malloc(n * sizeof(HuffmanNode));
	for (i = 0; i < n; ++i)     // ������a�е�Ȩֵ��������е�weight
	{
		temp[i] = (HuffmanNode*)malloc(sizeof(HuffmanNode));
		temp[i]->weight = a[i];
		temp[i]->id = i;
		temp[i]->lchild = temp[i]->rchild = NULL;
	}
	for (i = 0; i < n - 1; ++i)       // ��������������Ҫn-1�ϲ�
	{
		int small1 = -1, small2;      // small1��small2�ֱ���Ϊ��С�ʹ�СȨֵ���±�
		for (j = 0; j < n; ++j)         // �Ƚ���С�������±긳��small1��small2
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
				if (temp[j]->weight < temp[small1]->weight)  // �Ƚ�Ȩֵ��Ų��small1��small2ʹ֮�ֱ��Ϊ��С�ʹ�СȨֵ���±�
				{
					small2 = small1;
					small1 = j;
				}
				else if (temp[j]->weight < temp[small2]->weight)  // �Ƚ�Ȩֵ��Ų��small1��small2ʹ֮�ֱ��Ϊ��С�ʹ�СȨֵ���±�
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

// �Թ�������ʽ��ӡ��������
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


// �ݹ���й���������
void HuffmanCode(HuffmanNode* hufmTree, int depth,char string[])      // depthΪ�������������
{
	static int code[10];
	if (hufmTree)
	{
		if (hufmTree->lchild == NULL && hufmTree->rchild == NULL)
		{
			printf("%c�Ĺ���������Ϊ�� ",string[hufmTree->id]);
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

//����������
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

// ����������
void HuffmanDecode(char ch[], HuffmanNode* hufmTree, char string[])     // ch��Ҫ�����01����string�ǽ���Ӧ���ַ�
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
			printf("%c", string[tempTree->id]);     // ���������Ӧ�����ַ�
		}
	}
}

//������
int main()
{
	printf("������������:");
	int i, n;
	printf("�������ַ��ĸ�����\n");
	while (1)
	{
		scanf("%d", &n);
		if (n > 1)
			break;
		else
			printf("����������������룡");
	}

	int* arr;
	arr = (int*)malloc(n * sizeof(int));
	printf("������%d���ַ����ֵ�Ƶ�ȣ�\n", n);
	for (i = 0; i < n; ++i)
	{
		scanf("%d", &arr[i]);
	}

	char ch[100], string[100],c;
	printf("������������%d��Ƶ�ȸ�����������ַ���\n", n);
	fflush(stdin);      // ǿ����������е����ݣ�Ҳ������������Ȩֵ����ʱ�Ļس���
	gets(string);

	HuffmanNode* hufmTree = NULL;
	hufmTree = createHuffmanTree(arr, n);

	printf("�˹��������Ĺ������ʽΪ��\n");
	PrintHuffmanTree(hufmTree);

	printf("\n���ַ��Ĺ���������Ϊ��\n");
	HuffmanCode(hufmTree, 0, string);

	printf("\ne:����(Encode)\nd:����(Decode)\nq:�˳�(Quit))\n");
	printf("��ѡ�������");
	scanf("%c",&c);
	printf("\n");
	do
	{
		switch (c)
		{
			case'e':
			{
				printf("��������Ҫ������ı���");
				fflush(stdin); 
				gets(ch);
				printf("������Ϊ��\n");
				HuffmanEncode(hufmTree, ch, string, arr);
				printf("\n");
				printf("\ne:����(Encode)\nd:����(Decode)\nq:�˳�(Quit))\n");
				printf("��ѡ�������");
				break;
			}
			case'd':
			{
				printf("��������Ҫ����ĵ��ģ�");
				fflush(stdin); 
				gets(ch);
				printf("������Ϊ��\n");
				HuffmanDecode(ch, hufmTree, string);
				printf("\n");
				printf("\ne:����(Encode)\nd:����(Decode)\nq:�˳�(Quit))\n");
				printf("��ѡ�������");
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
