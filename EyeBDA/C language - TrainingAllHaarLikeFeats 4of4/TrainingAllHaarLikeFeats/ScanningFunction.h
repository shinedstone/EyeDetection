#define	BASIC_RESLT		16
#define	LevelDiff		1.25
#define NumOfNode		01

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

typedef struct CSL_DoubleToSort
{
	double value;
	int index;

}CSL_DoubleToSort;


CSL_RectFeatOutput RectFeatValueIN(unsigned char type, int size_x, int size_y, int start_x, int start_y, long long *ImgIntgMat, unsigned WidthImg);
void LoadingImgPatch(CSL_ImgPatch* ImagePatch,int WinSizeX, int WinSizeY, int startX, int startY);
long long SumValuesInPatch(CSL_ImgPatch* ImagePatch, long long *ImgIntgMat, unsigned int WidthImg);
void MeanStdImgPatch(CSL_ImgPatch* ImagePatch, long long *ImgIntgMat, long long *ImgIntgSqMat, unsigned int WidthImg);
void LoadingNodeClassifierIN(CSL_StrongClassifier* NodeClassifier, unsigned char nNode, double ScaleRatio);
void FreeNodeClassifier(CSL_StrongClassifier* NodeClassifier, unsigned char nNode);
double NodeClassificationIN(CSL_StrongClassifier* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, unsigned int WidthImg, CSL_ImgPatch* ImgPat);

double RectFeatValueD(unsigned char type, int size_x, int size_y, int start_x, int start_y, double *ImgIntgMat, unsigned int WidthImg);
void BobbleSort(double* Data, double *SortedData, int NumData, int *Index);
int CompareStruct (const void * a, const void * b);
double FindMin(double *Data, int NumData, int *MinIndex);

long long RectFeatValue(unsigned char type, int size_x, int size_y, int start_x, int start_y, long long *ImgIntgMat);
void LoadingNodeClassifier(CSL_StrongClassifier* NodeClassifier, unsigned char nNode, float ScaleRatio);
int NodeClassification(CSL_StrongClassifier* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, CSL_ImgPatch* ImgPat);