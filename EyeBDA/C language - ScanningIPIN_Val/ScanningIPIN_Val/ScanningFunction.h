#define		BASIC_RESLT					16

//#define WIDTHBYTES(bits)		(((bits)+31)/32*4)		// 영상의 가로줄은 4바이트의 배수

typedef struct CSL_ImgPatch

{
	int	StartX;
	int	StartY;
	int SizeX;
	int SizeY;
	double MeanPix;
	double StdPix;

}CSL_ImgPatch;

typedef struct CSL_RectFeat
{
	unsigned char Type;
	int SizeY;
	int SizeX;
	int StartY;
	int StartX;
	double Threshold;
	int Polarity;

}CSL_RectFeat;

typedef struct CSL_RectFeatOutput
{
	long long FeatValue;
	int AreaPlus;
	int AreaMinus;

}CSL_RectFeatOutput;

typedef struct CSL_StrongClassifier
{
	unsigned short nHaarFeat;
	CSL_RectFeat *HaarFeat;
	double	*Weights;
	double	EnTheta;

}CSL_StrongClassifier;

typedef struct CSL_StrongClassifierBDA
{
	unsigned short nHaarFeat;
	unsigned short nBDAFeat;
	CSL_RectFeat *HaarFeat;
	double	*Weights;
	double  *MeanTrainPos;
	double	EnTheta;	

}CSL_StrongClassifierBDA;

CSL_RectFeatOutput RectFeatValueIN(unsigned char type, int size_x, int size_y, int start_x, int start_y, long long *ImgIntgMat, unsigned WidthImg);
void LoadingImgPatch(CSL_ImgPatch* ImagePatch,int WinSizeX, int WinSizeY, int startX, int startY);
long long SumValuesInPatch(CSL_ImgPatch* ImagePatch, long long *ImgIntgMat, unsigned int WidthImg);
void MeanStdImgPatch(CSL_ImgPatch* ImagePatch, long long *ImgIntgMat, long long *ImgIntgSqMat, unsigned int WidthImg);
void LoadingNodeClassifierIN(CSL_StrongClassifier* NodeClassifier, unsigned char nNode, double ScaleRatio);
void LoadingNodeClassifierINBDA(CSL_StrongClassifierBDA* NodeClassifier, unsigned char nNode, double ScaleRatio);
void FreeNodeClassifier(CSL_StrongClassifier* NodeClassifier, unsigned char nNode);
void FreeNodeClassifierBDA(CSL_StrongClassifierBDA* NodeClassifier, unsigned char nNode);
unsigned char NodeClassificationIN(CSL_StrongClassifier* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, unsigned int WidthImg, CSL_ImgPatch* ImgPat, unsigned int* sum);
unsigned char NodeClassificationINBDA(CSL_StrongClassifierBDA* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, unsigned int WidthImg, CSL_ImgPatch* ImgPat, unsigned int* sum);

long long RectFeatValue(unsigned char type, int size_x, int size_y, int start_x, int start_y, long long *ImgIntgMat);
void LoadingNodeClassifier(CSL_StrongClassifier* NodeClassifier, unsigned char nNode, float ScaleRatio);
int NodeClassification(CSL_StrongClassifier* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, CSL_ImgPatch* ImgPat);

void ReadSizeOfGrayBMP(char *FileName, long* Height, long* Width);
void LoadingGrayBMP(char *FileName, unsigned char* ImgMat);
void IntgImg(unsigned char* ImgMat, long long* ImgMatIntg, long ImgHeight, long ImgWidth);
void IntgSqImg(unsigned char* ImgMat, long long* ImgMatIntgSq, long ImgHeight, long ImgWidth);
void ImageScaleDown(unsigned char* ImgMat, long ImgHeight, long ImgWidth,  unsigned char* ImgMatDown, float ScaleFactor);