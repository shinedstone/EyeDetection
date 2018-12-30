#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <windows.h>
#include <iostream>
#include <io.h>

#include "ScanningFunction.h"
#include "FaceDetect_Param_LAC.h"

void ReadSizeOfGrayBMP(char *FileName, long* Height, long* Width)
{
	FILE *infile;
	infile = fopen(FileName,"rb");
	if (infile==NULL) { printf("영상파일이없음\n"); exit(1);}

	// BMP 헤드 정보의 입력
	BITMAPFILEHEADER hf;
	BITMAPINFOHEADER hInfo;
	fread(&hf,sizeof(BITMAPFILEHEADER),1,infile);
	if (hf.bfType!=0x4D42) exit(1);
	fread(&hInfo,sizeof(BITMAPINFOHEADER),1,infile);
	if (hInfo.biBitCount!=8) { printf("BMP File is not gray!!"); exit(1); }; //흑백인지 체크
	fclose(infile);

	*Height = hInfo.biHeight;
	*Width = hInfo.biWidth;
	
}

void LoadingGrayBMP(char *FileName, unsigned char* ImgMat)
{
	FILE *infile;
	int i,j,ImgWidth4;
	unsigned char* ImgMatRvs;

	infile = fopen(FileName,"rb");
	if (infile==NULL) { printf("영상파일이없음\n"); exit(1);}

	// BMP 헤드 정보의 입력
	BITMAPFILEHEADER hf;
	BITMAPINFOHEADER hInfo;
	fread(&hf,sizeof(BITMAPFILEHEADER),1,infile);
	if (hf.bfType!=0x4D42) exit(1);
	fread(&hInfo,sizeof(BITMAPINFOHEADER),1,infile);
	if (hInfo.biBitCount!=8) { printf("BMP File is not gray!!"); exit(1); }; //흑백인지 체크

	ImgWidth4 = ((hInfo.biWidth-1)/4+1)*4;
	
	ImgMatRvs = (unsigned char*)malloc(sizeof(unsigned char)*ImgWidth4*hInfo.biHeight);
	// 팔레트 정보의 입력
	RGBQUAD hRGB[256];
	fread(hRGB,sizeof(RGBQUAD),256,infile);
	
	fread(ImgMatRvs,sizeof(char),hInfo.biSizeImage,infile);
	fclose(infile);

	// 파일에 역상으로 저장된 영상정보를 배열에 뒤집어서 저장
	for (i=0;i<hInfo.biHeight;i++) {
		for (j=0;j<hInfo.biWidth;j++) {
			ImgMat[i*ImgWidth4+j] = ImgMatRvs[(hInfo.biHeight-i-1)*ImgWidth4+j];
			//ImgMat[i*hInfo.biWidth+j] = ImgMatRvs[(hInfo.biHeight-i-1)*rwsize+j];
		}
	}	
	
}

void IntgImg(unsigned char* ImgMat, long long* ImgMatIntg, long ImgHeight, long ImgWidth)
{
	int i, j;

	unsigned int *ImgMatRowSum = (unsigned int *)malloc(sizeof(unsigned int)*ImgHeight*ImgWidth);

	for (i=0;i<ImgHeight;i++) {
		for (j=0;j<ImgWidth;j++) {
			if (i==0) {
				ImgMatRowSum[i*ImgWidth+j] = ImgMat[i*ImgWidth+j];
			}
			else {
				ImgMatRowSum[i*ImgWidth+j] = ImgMatRowSum[(i-1)*ImgWidth+j] + ImgMat[i*ImgWidth+j];
			}
		}
	}
	for (i=0;i<ImgHeight;i++) {
		for (j=0;j<ImgWidth;j++) {
			if (j==0) {
				ImgMatIntg[i*ImgWidth+j] = ImgMatRowSum[i*ImgWidth+j];
			}
			else {
				ImgMatIntg[i*ImgWidth+j] = ImgMatIntg[i*ImgWidth+(j-1)] + ImgMatRowSum[i*ImgWidth+j];
			}
		}
	}

	free(ImgMatRowSum);
}


void IntgSqImg(unsigned char* ImgMat, long long* ImgMatIntgSq, long ImgHeight, long ImgWidth)
{
	int i, j;

	long long *ImgMatRowSum = (long long *)malloc(sizeof(long long)*ImgHeight*ImgWidth);

	for (i=0;i<ImgHeight;i++) {
		for (j=0;j<ImgWidth;j++) {
			if (i==0) {
				ImgMatRowSum[i*ImgWidth+j] = ImgMat[i*ImgWidth+j]*ImgMat[i*ImgWidth+j];
			}
			else {
				ImgMatRowSum[i*ImgWidth+j] = ImgMatRowSum[(i-1)*ImgWidth+j] + ImgMat[i*ImgWidth+j]*ImgMat[i*ImgWidth+j];
			}
		}
	}
	for (i=0;i<ImgHeight;i++) {
		for (j=0;j<ImgWidth;j++) {
			if (j==0) {
				ImgMatIntgSq[i*ImgWidth+j] = ImgMatRowSum[i*ImgWidth+j];
			}
			else {
				ImgMatIntgSq[i*ImgWidth+j] = ImgMatIntgSq[i*ImgWidth+(j-1)] + ImgMatRowSum[i*ImgWidth+j];
			}
		}
	}

	free(ImgMatRowSum);
}

void ImageScaleDown(unsigned char* ImgMat, long ImgHeight, long ImgWidth,  unsigned char* ImgMatDown, float ScaleFactor)
{
	int i, j, RowOri, ColOri, point1, point2, point3, point4;
	long ImgHeightNew, ImgWidthNew;
	float DistRow, DistCol, Pix1, Pix2, Pix3, Pix4;
	//double SumTemp;
	//unsigned char* ImgMatSmooth = (unsigned char*)malloc(sizeof(unsigned char)*ImgWidth*ImgHeight);
	
	ImgHeightNew = (long)(ImgHeight*ScaleFactor+0.5);
	ImgWidthNew = (long)(ImgWidth*ScaleFactor+0.5);
	/*
	for (i=0;i<ImgHeight;i++) {
		for (j=0;j<ImgWidth;j++) {			
			SumTemp = 0;
			KernelIndex = 0;
			for (m=-2;m<3;m++) {
				for (n=-2;n<3;n++) {					
					if ( ((i+m)>=0) && ((i+m)<ImgHeight) && ((j+n)>=0) && ((j+n)<ImgWidth) ) {
						SumTemp = SumTemp + (double)ImgMat[(i+m)*ImgWidth+(j+n)]*Kernel[KernelIndex];
					}
					else {
						SumTemp = SumTemp + (double)ImgMat[(i)*ImgWidth+(j)]*Kernel[KernelIndex];
					}
					KernelIndex = KernelIndex + 1;
				}
			}
			ImgMatSmooth[i*ImgWidth+j] = (unsigned char)(SumTemp+0.5);			
		}
	}*/
			

	for (i=0;i<ImgHeightNew;i++) {
		for (j=0;j<ImgWidthNew;j++) {
			
			RowOri = (long)((i+1)/ScaleFactor);
			ColOri = (long)((j+1)/ScaleFactor);
			
			RowOri = (RowOri<1?1:RowOri);
			RowOri = (RowOri>=ImgHeight-1?ImgHeight-1:RowOri);

			ColOri = (ColOri<1?1:ColOri);
			ColOri = (ColOri>=ImgWidth-1?ImgWidth-1:ColOri);

			DistRow = ((i+1)/ScaleFactor) - RowOri;
			DistCol = ((j+1)/ScaleFactor) - ColOri;
			
			point1 = (RowOri-1)*ImgWidth+(ColOri-1);
			point2 = (RowOri-1)*ImgWidth+(ColOri);
			point3 = (RowOri)*ImgWidth+(ColOri-1);
			point4 = (RowOri)*ImgWidth+(ColOri);

			//printf("(%d,%d) / (%d,%d) ; p1:%d, p2:%d, p3:%d, p4:%d (%d)\n",ColOri,RowOri,ImgWidth,ImgHeight,point1,point2,point3,point4,ImgWidth*ImgHeight-1);
			
			Pix1 = (float)ImgMat[point1];
			Pix2 = (float)ImgMat[point2];
			Pix3 = (float)ImgMat[point3];
			Pix4 = (float)ImgMat[point4];
			//printf("%f, %f, %f, %f\n",Pix1,Pix2,Pix3,Pix4);

			ImgMatDown[i*ImgWidthNew+j] = (unsigned char) (Pix1*(1-DistRow)*(1-DistCol)+Pix2*(1-DistRow)*(DistCol)+Pix3*(DistRow)*(1-DistCol)+Pix4*(DistRow)*(DistCol) + 0.5);
			
			//RowOri = (long)(i/ScaleFactor+0.5);
			//ColOri = (long)(j/ScaleFactor+0.5);
			//ImgMatDown[i*ImgWidthNew+j] = ImgMatSmooth[RowOri*ImgWidth+ColOri];

		}
	}

	//free(ImgMatSmooth);
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

void FreeNodeClassifierBDA(CSL_StrongClassifierBDA* NodeClassifier, unsigned char nNode)
{
	int k;
	for (k=0;k<nNode;k++) {
		free(NodeClassifier[k].HaarFeat);
	}
}

unsigned char NodeClassificationIN(CSL_StrongClassifier* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, unsigned int WidthImg, CSL_ImgPatch* ImgPat, unsigned int* sum)
{
	int i=0;
	unsigned char Flag, type;
	int size_y, size_x, start_y, start_x, polarity;
	double OutValue, threshold, OutValueTotal=0;
	
	CSL_RectFeatOutput Output_RectFeat;
	
	for (i=0;i<NodeClassifier[NodeIndex].nHaarFeat;i++) {
		
		type	= (NodeClassifier[NodeIndex].HaarFeat)[i].Type;
		size_y	= (NodeClassifier[NodeIndex].HaarFeat)[i].SizeY;
		size_x	= (NodeClassifier[NodeIndex].HaarFeat)[i].SizeX;
		start_y = (NodeClassifier[NodeIndex].HaarFeat)[i].StartY + ImgPat->StartY;
		start_x = (NodeClassifier[NodeIndex].HaarFeat)[i].StartX + ImgPat->StartX;		
				
		Output_RectFeat = RectFeatValueIN(type,size_x,size_y,start_x,start_y,ImgIntgMat,WidthImg);
											
		polarity  = (NodeClassifier[NodeIndex].HaarFeat)[i].Polarity;
		threshold = (NodeClassifier[NodeIndex].HaarFeat)[i].Threshold;
				
		OutValue = 0;
		if (Output_RectFeat.AreaMinus==Output_RectFeat.AreaPlus) {
			if (ImgPat->StdPix==0) {
				OutValue = (double)(Output_RectFeat.FeatValue);
			}
			else {
				OutValue = (double)(Output_RectFeat.FeatValue)/ImgPat->StdPix;
			}
		}
		else {
			if (ImgPat->StdPix==0) {
				OutValue = (double)(Output_RectFeat.FeatValue-(Output_RectFeat.AreaPlus-Output_RectFeat.AreaMinus)*ImgPat->MeanPix);
			}
			else {
				OutValue = (double)(Output_RectFeat.FeatValue-(Output_RectFeat.AreaPlus-Output_RectFeat.AreaMinus)*ImgPat->MeanPix)/ImgPat->StdPix;
			}
		}
		//printf("Type:%d, Size:%dx%d, Start:(%d,%d), Polarity:%d,  Threshold:%lf\n",type,size_x,size_y,start_x,start_y,polarity,threshold);
		//printf("=> OutValue:%lf\n",OutValue);
		if (polarity*OutValue>=polarity*threshold) {
			OutValueTotal = OutValueTotal + (NodeClassifier[NodeIndex].Weights)[i];
			//printf("%lf\n",(NodeClassifier[NodeIndex].Weights)[i]);
			(*sum)++;
		}		
	}
	//printf("TotalOutValue = %lf\n",OutValueTotal);

	if (OutValueTotal >= NodeClassifier[NodeIndex].EnTheta) Flag = 1;
	else Flag = 0;
	
	return Flag;

}	

unsigned char NodeClassificationINBDA(CSL_StrongClassifierBDA* NodeClassifier, unsigned char NodeIndex, long long* ImgIntgMat, unsigned int WidthImg, CSL_ImgPatch* ImgPat, unsigned int* sum)
{
	int i=0, k=0;
	unsigned char Flag, type;
	int size_y, size_x, start_y, start_x, polarity;
	double OutValue, threshold, OutValueTotal=0;

	int* HaarFeatVec = (int *)malloc(sizeof(int)*NodeClassifier[NodeIndex].nHaarFeat);
	double* OutFeatVec = (double *)malloc(sizeof(double)*NodeClassifier[NodeIndex].nBDAFeat);

	CSL_RectFeatOutput Output_RectFeat;	

	for (i=0;i<NodeClassifier[NodeIndex].nHaarFeat;i++) HaarFeatVec[i]=0;	
	for (i=0;i<NodeClassifier[NodeIndex].nHaarFeat;i++) {
		
		type	= (NodeClassifier[NodeIndex].HaarFeat)[i].Type;
		size_y	= (NodeClassifier[NodeIndex].HaarFeat)[i].SizeY;
		size_x	= (NodeClassifier[NodeIndex].HaarFeat)[i].SizeX;
		start_y = (NodeClassifier[NodeIndex].HaarFeat)[i].StartY + ImgPat->StartY;
		start_x = (NodeClassifier[NodeIndex].HaarFeat)[i].StartX + ImgPat->StartX;		
				
		Output_RectFeat = RectFeatValueIN(type,size_x,size_y,start_x,start_y,ImgIntgMat,WidthImg);
											
		polarity  = (NodeClassifier[NodeIndex].HaarFeat)[i].Polarity;
		threshold = (NodeClassifier[NodeIndex].HaarFeat)[i].Threshold;
				
		OutValue = 0;
		if (Output_RectFeat.AreaMinus==Output_RectFeat.AreaPlus) {
			if (ImgPat->StdPix==0) {
				OutValue = (double)(Output_RectFeat.FeatValue);
			}
			else {
				OutValue = (double)(Output_RectFeat.FeatValue)/ImgPat->StdPix;
			}
		}
		else {
			if (ImgPat->StdPix==0) {
				OutValue = (double)(Output_RectFeat.FeatValue-(Output_RectFeat.AreaPlus-Output_RectFeat.AreaMinus)*ImgPat->MeanPix);
			}
			else {
				OutValue = (double)(Output_RectFeat.FeatValue-(Output_RectFeat.AreaPlus-Output_RectFeat.AreaMinus)*ImgPat->MeanPix)/ImgPat->StdPix;
			}
		}
		if (polarity*OutValue>=polarity*threshold) {
			HaarFeatVec[i] = 1;
			(*sum)++;
		}		
	}

	for(k=0;k<NodeClassifier[NodeIndex].nBDAFeat;k++) {
		OutValue = 0;
		for (i=0;i<NodeClassifier[NodeIndex].nHaarFeat;i++) {
			OutValue = OutValue + (HaarFeatVec[i]-NodeClassifier[NodeIndex].MeanTrainPos[i])*(NodeClassifier[NodeIndex].Weights)[NodeClassifier[NodeIndex].nBDAFeat*i+k];
		}
		OutFeatVec[k] = OutValue;

		OutValueTotal = OutValueTotal + (OutFeatVec[k]*OutFeatVec[k]);
	}
	OutValueTotal = sqrt(OutValueTotal);
	
	free(OutFeatVec);
	free(HaarFeatVec);

	if (OutValueTotal < NodeClassifier[NodeIndex].EnTheta) Flag = 1;
	else Flag = 0;
	
	return Flag;

}	

void LoadingNodeClassifierINBDA(CSL_StrongClassifierBDA* NodeClassifier, unsigned char nNode, double ScaleRatio)
{
	int i,k;
	for (k=0;k<nNode;k++) {
		NodeClassifier[k].nHaarFeat = NumOfHaarFeatsEachNode[k];
		NodeClassifier[k].nBDAFeat = NumOfBDAFeatsEachNode[k];
		NodeClassifier[k].EnTheta = EnTheta[k];
		NodeClassifier[k].HaarFeat = (CSL_RectFeat *)malloc(sizeof(CSL_RectFeat)*NodeClassifier[k].nHaarFeat);

		switch (k)	{
			case 0:
				NodeClassifier[k].Weights = Weights01;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos01;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats01[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats01[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats01[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats01[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats01[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats01[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds01[i] * ScaleRatio * ScaleRatio;
					
				}				
				
				break;
			
			case 1:
				NodeClassifier[k].Weights = Weights02;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos02;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats02[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats02[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats02[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats02[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats02[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats02[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds02[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 2:
				NodeClassifier[k].Weights = Weights03;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos03;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats03[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats03[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats03[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats03[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats03[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats03[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds03[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 3:
				NodeClassifier[k].Weights = Weights04;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos04;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats04[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats04[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats04[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats04[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats04[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats04[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds04[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 4:
				NodeClassifier[k].Weights = Weights05;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos05;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats05[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats05[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats05[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats05[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats05[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats05[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds05[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 5:
				NodeClassifier[k].Weights = Weights06;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos06;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats06[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats06[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats06[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats06[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats06[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats06[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds06[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			  
			case 6:
				NodeClassifier[k].Weights = Weights07;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos07;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats07[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats07[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats07[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats07[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats07[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats07[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds07[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;

			case 7:
				NodeClassifier[k].Weights = Weights08;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos08;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats08[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats08[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats08[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats08[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats08[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats08[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds08[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 8:
				NodeClassifier[k].Weights = Weights09;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos09;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats09[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats09[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats09[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats09[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats09[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats09[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds09[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 9:
				NodeClassifier[k].Weights = Weights10;
				NodeClassifier[k].MeanTrainPos = MeanTrainPos10;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats10[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats10[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats10[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats10[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats10[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats10[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds10[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			/*
			case 10:
				NodeClassifier[k].Weights = Weights11;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats11[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats11[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats11[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats11[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats11[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats11[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds11[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 11:
				NodeClassifier[k].Weights = Weights12;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats12[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats12[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats12[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats12[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats12[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats12[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds12[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 12:
				NodeClassifier[k].Weights = Weights13;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats13[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats13[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats13[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats13[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats13[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats13[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds13[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 13:
				NodeClassifier[k].Weights = Weights14;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats14[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats14[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats14[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats14[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats14[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats14[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds14[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 14:
				NodeClassifier[k].Weights = Weights15;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats15[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats15[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats15[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats15[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats15[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats15[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds15[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 15:
				NodeClassifier[k].Weights = Weights16;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats16[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats16[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats16[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats16[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats16[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats16[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds16[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 16:
				NodeClassifier[k].Weights = Weights17;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats17[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats17[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats17[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats17[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats17[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats17[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds17[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 17:
				NodeClassifier[k].Weights = Weights18;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats18[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats18[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats18[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats18[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats18[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats18[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds18[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 18:
				NodeClassifier[k].Weights = Weights19;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats19[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats19[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats19[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats19[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats19[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats19[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds19[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 19:
				NodeClassifier[k].Weights = Weights20;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats20[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats20[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats20[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats20[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats20[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats20[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds20[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 20:
				NodeClassifier[k].Weights = Weights21;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats21[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats21[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats21[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats21[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats21[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats21[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds21[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 21:
				NodeClassifier[k].Weights = Weights22;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats22[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats22[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats22[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats22[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats22[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats22[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds22[i] * ScaleRatio * ScaleRatio;
				}				
				
				break;
			
			case 22:
				NodeClassifier[k].Weights = Weights23;
				for (i=0;i<NodeClassifier[k].nHaarFeat;i++) {
					(NodeClassifier[k].HaarFeat)[i].Type =		             HaarFeats23[i*6+0];
					(NodeClassifier[k].HaarFeat)[i].SizeY =		(int)((float)HaarFeats23[i*6+1] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].SizeX =		(int)((float)HaarFeats23[i*6+2] * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartY =	(int)((float)(HaarFeats23[i*6+3]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].StartX =	(int)((float)(HaarFeats23[i*6+4]-1) * ScaleRatio + 0.5);
					(NodeClassifier[k].HaarFeat)[i].Polarity =				 HaarFeats23[i*6+5];
					(NodeClassifier[k].HaarFeat)[i].Threshold =				 Thresholds23[i] * ScaleRatio * ScaleRatio;
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
			*/
			default:
				printf("NodeIndex Check!\n");
		}
		
	}	
}		
