#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "ScanningFunction.h"
//#include "FaceDetect_Param.h"

void BobbleSort(double* Data, double *SortedData, int NumData, int *Index)
{
	double ValueTemp;
	int i,j, IndexTemp;

	for (i=0;i<NumData;i++) SortedData[i]=Data[i];

	for (i=NumData-1;i>0;i--) {
		for (j=0;j<i;j++) {
			if (SortedData[j]>SortedData[j+1])	{
				ValueTemp = SortedData[j];
				SortedData[j] = SortedData[j+1];
				SortedData[j+1] = ValueTemp;

				IndexTemp = Index[j];
				Index[j] = Index[j+1];
				Index[j+1] = IndexTemp;
			}
		}
	}
}

int CompareStruct (const void * a, const void * b)
{
  if ( ((CSL_DoubleToSort *)a)->value >  ((CSL_DoubleToSort *)b)->value ) return 1;
  if ( ((CSL_DoubleToSort *)a)->value == ((CSL_DoubleToSort *)b)->value ) return 0;
  if ( ((CSL_DoubleToSort *)a)->value <  ((CSL_DoubleToSort *)b)->value ) return -1;
}

double FindMin(double *Data, int NumData, int *MinIndex)
{
	int i=0;
	double MinValue;

	MinValue = Data[0];
	for (i=1;i<NumData;i++) {
		if (Data[i]<MinValue) {
			MinValue = Data[i];
			*MinIndex = i;
		}
	}

	return MinValue;
}

double RectFeatValueD(unsigned char type, int size_x, int size_y, int start_x, int start_y, double *ImgIntgMat, unsigned int WidthImg)
{
	double OutValue=0;
		
	if (type == 1) {
		int x1, x2, x3, x4;
		int y1, y2;
		
		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/3)+0.5);
		x3 = start_x - 1 - (int)(((float)size_x/3)+0.5) + size_x;
		x4 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + size_y;
		
		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x4];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x4];
		OutValue = OutValue + 2*ImgIntgMat[y1*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

	}
	else if (type == 2) {
		int x1, x2, x3;
		int y1, y2;

		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/2)+0.5);
		x3 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x1];

	}
	else if (type == 3) {
		int x1, x2;
		int y1, y2, y3;
		
		x1 = start_x - 1;
		x2 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/2)+0.5);
		y3 = start_y - 1 + size_y;
		
		OutValue = OutValue +   ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y3*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x1];

	}
	else if (type == 4) {

		int x1, x2;
		int y1, y2, y3, y4;

		x1 = start_x - 1;
		x2 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/3)+0.5);
		y3 = start_y - 1 - (int)(((float)size_y/3)+0.5) + size_y;
		y4 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y4*WidthImg+x2];
		OutValue = OutValue - 2*ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y4*WidthImg+x1];
		OutValue = OutValue + 2*ImgIntgMat[y3*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

	}
	else if (type == 5) {

		int x1, x2, x3, x4;
		int y1, y2;
		
		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/4)+0.5);
		x3 = start_x - 1 - (int)(((float)size_x/4)+0.5) + size_x;
		x4 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + size_y;
		
		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x4];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x4];
		OutValue = OutValue + 2*ImgIntgMat[y1*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

	}
	else if (type == 6) {

		int x1, x2;
		int y1, y2, y3, y4;

		x1 = start_x - 1;
		x2 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/4)+0.5);
		y3 = start_y - 1 - (int)(((float)size_y/4)+0.5) + size_y;
		y4 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y4*WidthImg+x2];
		OutValue = OutValue - 2*ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y4*WidthImg+x1];
		OutValue = OutValue + 2*ImgIntgMat[y3*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

	}
	else if (type == 7) {

		int x1, x2, x3, x4;
		int y1, y2, y3, y4;

		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/3)+0.5);
		x3 = start_x - 1 - (int)(((float)size_x/3)+0.5) + size_x;
		x4 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/3)+0.5);
		y3 = start_y - 1 - (int)(((float)size_y/3)+0.5) + size_y;
		y4 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y4*WidthImg+x4];
		OutValue = OutValue -   ImgIntgMat[y4*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y3*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x4];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

	}
	else {
		printf("HaarFeat. Type Error!!\n");
		exit(1);
	}
		
	return OutValue;	
}


CSL_RectFeatOutput RectFeatValueIN(unsigned char type, int size_x, int size_y, int start_x, int start_y, long long *ImgIntgMat, unsigned int WidthImg)
{
	long long OutValue=0;
	int Area1,Area2;
	
	CSL_RectFeatOutput RectFeat;

	if (type == 1) {
		int x1, x2, x3, x4;
		int y1, y2;
		
		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/3)+0.5);
		x3 = start_x - 1 - (int)(((float)size_x/3)+0.5) + size_x;
		x4 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + size_y;
		
		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x4];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x4];
		OutValue = OutValue + 2*ImgIntgMat[y1*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

		Area1 = (x2-x1)*(y2-y1) + (x4-x3)*(y2-y1);
		Area2 = (x3-x2)*(y2-y1);

	}
	else if (type == 2) {
		int x1, x2, x3;
		int y1, y2;

		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/2)+0.5);
		x3 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x1];

		Area1 = (x3-x2)*(y2-y1);
		Area2 = (x2-x1)*(y2-y1);

	}
	else if (type == 3) {
		int x1, x2;
		int y1, y2, y3;
		
		x1 = start_x - 1;
		x2 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/2)+0.5);
		y3 = start_y - 1 + size_y;
		
		OutValue = OutValue +   ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y3*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x1];

		Area1 = (x2-x1)*(y3-y2);
		Area2 = (x2-x1)*(y2-y1);

	}
	else if (type == 4) {

		int x1, x2;
		int y1, y2, y3, y4;

		x1 = start_x - 1;
		x2 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/3)+0.5);
		y3 = start_y - 1 - (int)(((float)size_y/3)+0.5) + size_y;
		y4 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y4*WidthImg+x2];
		OutValue = OutValue - 2*ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y4*WidthImg+x1];
		OutValue = OutValue + 2*ImgIntgMat[y3*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

		Area1 = (x2-x1)*(y2-y1) + (x2-x1)*(y4-y3);
		Area2 = (x2-x1)*(y3-y2);
	}
	else if (type == 5) {

		int x1, x2, x3, x4;
		int y1, y2;
		
		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/4)+0.5);
		x3 = start_x - 1 - (int)(((float)size_x/4)+0.5) + size_x;
		x4 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + size_y;
		
		OutValue = OutValue +   ImgIntgMat[y2*WidthImg+x4];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x4];
		OutValue = OutValue + 2*ImgIntgMat[y1*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

		Area1 = (x2-x1)*(y2-y1) + (x4-x3)*(y2-y1);
		Area2 = (x3-x2)*(y2-y1);

	}
	else if (type == 6) {

		int x1, x2;
		int y1, y2, y3, y4;

		x1 = start_x - 1;
		x2 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/4)+0.5);
		y3 = start_y - 1 - (int)(((float)size_y/4)+0.5) + size_y;
		y4 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y4*WidthImg+x2];
		OutValue = OutValue - 2*ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y4*WidthImg+x1];
		OutValue = OutValue + 2*ImgIntgMat[y3*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x1];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

		Area1 = (x2-x1)*(y2-y1) + (x2-x1)*(y4-y3);
		Area2 = (x2-x1)*(y3-y2);

	}
	else if (type == 7) {

		int x1, x2, x3, x4;
		int y1, y2, y3, y4;

		x1 = start_x - 1;
		x2 = start_x - 1 + (int)(((float)size_x/3)+0.5);
		x3 = start_x - 1 - (int)(((float)size_x/3)+0.5) + size_x;
		x4 = start_x - 1 + size_x;

		y1 = start_y - 1;
		y2 = start_y - 1 + (int)(((float)size_y/3)+0.5);
		y3 = start_y - 1 - (int)(((float)size_y/3)+0.5) + size_y;
		y4 = start_y - 1 + size_y;

		OutValue = OutValue +   ImgIntgMat[y4*WidthImg+x4];
		OutValue = OutValue -   ImgIntgMat[y4*WidthImg+x1];
		OutValue = OutValue - 2*ImgIntgMat[y3*WidthImg+x3];
		OutValue = OutValue + 2*ImgIntgMat[y3*WidthImg+x2];
		OutValue = OutValue + 2*ImgIntgMat[y2*WidthImg+x3];
		OutValue = OutValue - 2*ImgIntgMat[y2*WidthImg+x2];
		OutValue = OutValue -   ImgIntgMat[y1*WidthImg+x4];
		OutValue = OutValue +   ImgIntgMat[y1*WidthImg+x1];

		Area1 = (x4-x1)*(y4-y1) - (x3-x2)*(y3-y2);
		Area2 = (x3-x2)*(y3-y2);

	}
	else {
		printf("HaarFeat. Type Error!!\n");
		exit(1);
	}	
	
	RectFeat.AreaPlus = Area1;
	RectFeat.AreaMinus = Area2;
	RectFeat.FeatValue = OutValue;
	
	return RectFeat;	
}


void LoadingImgPatch(CSL_ImgPatch* ImagePatch, int WinSizeX, int WinSizeY, int startX, int startY)
{
	ImagePatch->StartX = startX;
	ImagePatch->StartY = startY;
	ImagePatch->SizeX = WinSizeX;
	ImagePatch->SizeY = WinSizeY;
	ImagePatch->MeanPix = 0;
	ImagePatch->StdPix = 0;
}

long long SumValuesInPatch(CSL_ImgPatch *ImagePatch, long long *ImgIntgMat, unsigned int WidthImg)
{
	long long SumPix=0;
	int x1, x2, y1, y2;

	x1 = ImagePatch->StartX - 1;
	y1 = ImagePatch->StartY - 1;
	x2 = ImagePatch->StartX + ImagePatch->SizeX - 1;
	y2 = ImagePatch->StartY + ImagePatch->SizeY - 1;
	
	if ( (ImagePatch->StartX == 0) && (ImagePatch->StartY == 0) ) {
		SumPix = ImgIntgMat[y2*WidthImg+x2];

	} else if (ImagePatch->StartX == 0) {
		SumPix = ImgIntgMat[y2*WidthImg+x2];
		SumPix = SumPix - ImgIntgMat[y1*WidthImg+x2];

	} else if (ImagePatch->StartY == 0) {
		SumPix = ImgIntgMat[y2*WidthImg+x2];
		SumPix = SumPix - ImgIntgMat[y2*WidthImg+x1];

	} else {
		SumPix = ImgIntgMat[y2*WidthImg+x2];
		SumPix = SumPix - ImgIntgMat[y2*WidthImg+x1];
		SumPix = SumPix - ImgIntgMat[y1*WidthImg+x2];
		SumPix = SumPix + ImgIntgMat[y1*WidthImg+x1];
	}
	
	return SumPix;
}

void MeanStdImgPatch(CSL_ImgPatch *ImagePatch, long long *ImgIntgMat, long long *ImgIntgSqMat, unsigned int WidthImg)
{	
	long long TempSum=0;
	int NumOfPix;
	double ValueTemp=0;
		
	NumOfPix = (ImagePatch->SizeY)*(ImagePatch->SizeX);
	TempSum = SumValuesInPatch(ImagePatch,ImgIntgMat,WidthImg);
	ImagePatch->MeanPix = TempSum/(double)NumOfPix;
		
	TempSum = SumValuesInPatch(ImagePatch,ImgIntgSqMat,WidthImg);
	ValueTemp = TempSum/(double)(NumOfPix) - (ImagePatch->MeanPix)*(ImagePatch->MeanPix);
	ImagePatch->StdPix = sqrt(ValueTemp);
}

void FreeNodeClassifier(CSL_StrongClassifier* NodeClassifier, unsigned char nNode)
{
	int k;
	for (k=0;k<nNode;k++) {
		free(NodeClassifier[k].HaarFeat);
	}
}

double NodeClassificationIN(CSL_StrongClassifier* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, unsigned int WidthImg, CSL_ImgPatch* ImgPat)
{
	int i=0;
	unsigned char Flag, type;
	int size_y, size_x, start_y, start_x, polarity;
	long long HaarFeatOutPut=0;
	double OutValue=0, threshold;
	//double *W = Weights01;

	CSL_RectFeatOutput Output_RectFeat;
	
	for (i=0;i<NodeClassifier[NodeIndex].nHaarFeat;i++) {
		type	= (NodeClassifier[NodeIndex].HaarFeat)[i].Type;
		size_y	= (NodeClassifier[NodeIndex].HaarFeat)[i].SizeY;
		size_x	= (NodeClassifier[NodeIndex].HaarFeat)[i].SizeX;
		start_y = (NodeClassifier[NodeIndex].HaarFeat)[i].StartY + ImgPat->StartY - 1;		//현재 저장된 start_x & start_y 값은 (1,1)부터 시작한 좌표 (Matlab)
		start_x = (NodeClassifier[NodeIndex].HaarFeat)[i].StartX + ImgPat->StartX - 1;
		
		Output_RectFeat = RectFeatValueIN(type,size_x,size_y,start_x,start_y,ImgIntgMat,WidthImg);
								
		printf("Mean:%f, Std:%f\n",ImgPat->MeanPix,ImgPat->StdPix);
		polarity  = (NodeClassifier[NodeIndex].HaarFeat)[i].Polarity;
		threshold = (NodeClassifier[NodeIndex].HaarFeat)[i].Threshold;

		if (Output_RectFeat.AreaMinus==Output_RectFeat.AreaPlus) {
			OutValue = (double)(Output_RectFeat.FeatValue) / ImgPat->StdPix;
		}
		else {
			OutValue = (double)(Output_RectFeat.FeatValue - (Output_RectFeat.AreaPlus-Output_RectFeat.AreaMinus)*ImgPat->MeanPix ) / ImgPat->StdPix;
		}		
	}
		
	if (OutValue >= NodeClassifier[NodeIndex].EnTheta) Flag = 1;
	else Flag = 0;

	return OutValue;

}	
/*
void LoadingNodeClassifierIN(CSL_StrongClassifier* NodeClassifier, unsigned char nNode, double ScaleRatio)
{
	int i,k;
	for (k=0;k<nNode;k++) {
		NodeClassifier[k].nHaarFeat = NumOfHaarFeatsEachNode[k];
		NodeClassifier[k].EnTheta = EnTheta[k];
		NodeClassifier[k].HaarFeat = (CSL_RectFeat *)malloc(sizeof(CSL_RectFeat)*NodeClassifier[k].nHaarFeat);

		switch (k)	{
			case 0:
				NodeClassifier[k].Weights = Weights01;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats01[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats01[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats01[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats01[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats01[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 HaarFeats01[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats01[i*7+6];
				}				
				
				break;

			case 1:
				NodeClassifier[k].Weights = Weights02;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats02[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats02[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats02[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats02[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats02[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats02[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats02[i*7+6];
				}				
				
				break;

			case 2:
				NodeClassifier[k].Weights = Weights03;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats03[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats03[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats03[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats03[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats03[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats03[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats03[i*7+6];
				}				
				
				break;
			
			case 3:
				NodeClassifier[k].Weights = Weights04;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats04[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats04[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats04[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats04[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats04[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats04[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats04[i*7+6];
				}				
				
				break;

			case 4:
				NodeClassifier[k].Weights = Weights05;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats05[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats05[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats05[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats05[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats05[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats05[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats05[i*7+6];
				}				
				
				break;
			
			case 5:
				NodeClassifier[k].Weights = Weights06;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats06[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats06[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats06[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats06[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats06[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats06[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats06[i*7+6];
				}				
				
				break;
			
			case 6:
				NodeClassifier[k].Weights = Weights07;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats07[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats07[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats07[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats07[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats07[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats07[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats07[i*7+6];
				}				
				
				break;
				
			case 7:
				NodeClassifier[k].Weights = Weights08;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats08[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats08[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats08[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats08[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats08[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats08[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats08[i*7+6];
				}				
				
				break;

			case 8:
				NodeClassifier[k].Weights = Weights09;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats09[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats09[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats09[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats09[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats09[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats09[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats09[i*7+6];
				}				
				
				break;

			case 9:
				NodeClassifier[k].Weights = Weights10;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats10[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats10[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats10[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats10[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats10[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats10[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats10[i*7+6];
				}				
				
				break;

			case 10:
				NodeClassifier[k].Weights = Weights11;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats11[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats11[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats11[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats11[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats11[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats11[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats11[i*7+6];
				}				
				
				break;

			case 11:
				NodeClassifier[k].Weights = Weights12;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats12[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats12[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats12[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats12[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats12[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats12[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats12[i*7+6];
				}				
				
				break;

			case 12:
				NodeClassifier[k].Weights = Weights13;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats13[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats13[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats13[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats13[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats13[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats13[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats13[i*7+6];
				}				
				
				break;

			case 13:
				NodeClassifier[k].Weights = Weights14;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats14[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats14[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats14[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats14[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats14[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats14[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats14[i*7+6];
				}				
				
				break;

			case 14:
				NodeClassifier[k].Weights = Weights15;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats15[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats15[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats15[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats15[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats15[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats15[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats15[i*7+6];
				}				
				
				break;

			case 15:
				NodeClassifier[k].Weights = Weights16;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats16[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats16[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats16[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats16[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats16[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats16[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats16[i*7+6];
				}				
				
				break;
			
			case 16:
				NodeClassifier[k].Weights = Weights17;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats17[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats17[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats17[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats17[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats17[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats17[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats17[i*7+6];
				}				
				
				break;

			case 17:
				NodeClassifier[k].Weights = Weights18;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats18[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats18[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats18[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats18[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats18[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats18[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats18[i*7+6];
				}				
				
				break;

			case 18:
				NodeClassifier[k].Weights = Weights19;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats19[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats19[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats19[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats19[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats19[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats19[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats19[i*7+6];
				}				
				
				break;

			case 19:
				NodeClassifier[k].Weights = Weights20;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats20[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats20[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats20[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats20[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats20[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats20[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats20[i*7+6];
				}				
				
				break;

			case 20:
				NodeClassifier[k].Weights = Weights21;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats21[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats21[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats21[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats21[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats21[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats21[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats21[i*7+6];
				}				
				
				break;

			case 21:
				NodeClassifier[k].Weights = Weights22;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats22[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats22[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats22[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats22[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats22[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats22[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats22[i*7+6];
				}				
				
				break;

			case 22:
				NodeClassifier[k].Weights = Weights23;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats23[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats23[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats23[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats23[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats23[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats23[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats23[i*7+6];
				}				
				
				break;

			case 23:
				NodeClassifier[k].Weights = Weights24;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats24[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats24[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats24[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats24[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats24[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats24[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats24[i*7+6];
				}				
				
				break;

			case 24:
				NodeClassifier[k].Weights = Weights25;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats25[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats25[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats25[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats25[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats25[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats25[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats25[i*7+6];
				}				
				
				break;

			case 25:
				NodeClassifier[k].Weights = Weights26;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats26[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats26[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats26[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats26[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats26[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats26[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats26[i*7+6];
				}				
				
				break;


			case 26:
				NodeClassifier[k].Weights = Weights27;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats27[i*7+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats27[i*7+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats27[i*7+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)HaarFeats27[i*7+3] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)HaarFeats27[i*7+4] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Threshold = 			 HaarFeats27[i*7+5] * ScaleRatio * ScaleRatio;
					(NodeClassifier[k].HaarFeat)[i].Polarity =	             HaarFeats27[i*7+6];
				}				
				
				break;

			default:
				printf("NodeIndex Check!\n");
		}
		
	}	
}		
*/