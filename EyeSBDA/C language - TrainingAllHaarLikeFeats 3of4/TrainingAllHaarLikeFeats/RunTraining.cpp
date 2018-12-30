#include <iostream>
#include <stdlib.h>
#include <time.h>

#include "ScanningFunction.h"

#define		nSampPos		2800
#define		nSampNeg		2800
#define		WinX			18
#define		WinY			18
#define		NUM_HAARFEATS	5870

char ExperimentsIndex[] = "04";
char NodeIndex[] = "08";
//// 3/4
void main()
{
	int i, j, k, Idx[nSampPos+nSampNeg], nCorrect=0;
	int *TrainClass, TempInt, SizeX, SizeY, StartX, StartY, Polarity, HaarFeat[NUM_HAARFEATS*5];
	unsigned char Type;
	double EachSamp[WinX*WinY], *TrainSamp, TempDouble, FeatValues[nSampPos+nSampNeg], SortedFeatValues[nSampPos+nSampNeg], TimeStart, TimeEnd, W[nSampPos+nSampNeg];
	double Errors1[nSampPos+nSampNeg], Errors2[nSampPos+nSampNeg], Threshold, RecogRates, TimeStartTotal, TimeEndTotal;
	char StrTemp[500];

	CSL_DoubleToSort *DoubleNums = (CSL_DoubleToSort *)malloc(sizeof(CSL_DoubleToSort)*(nSampPos+nSampNeg));
	
	TimeStartTotal = clock();

	printf("Loading data files...\n");
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\HaarFeatInfo18x18_3of4.dat",ExperimentsIndex);
	FILE *FP_Haar = fopen(StrTemp,"rt");
	if (FP_Haar==NULL) printf("File open error! (File for Haar)\n");
	for (i=0;i<5*NUM_HAARFEATS;i++) {
		fscanf(FP_Haar,"%d",&TempInt);
		HaarFeat[i] = TempInt;
	}
	fclose(FP_Haar);

	TrainSamp = (double *)malloc(sizeof(double)*(nSampPos+nSampNeg)*(WinX*WinY)); 
	TrainClass = (int *)malloc(sizeof(int)*(nSampPos+nSampNeg));	
	
	TimeStart = clock();					
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\TrainSamplesIN_Node%s.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP = fopen(StrTemp,"rt");
	if (FP==NULL) printf("File open error! (File for FP)\n");
	for (i=0;i<(nSampPos+nSampNeg);i++) {	//(nSampPos+nSampNeg)
		for (j=0;j<(WinX*WinY);j++) {
			fscanf(FP,"%lf",&TempDouble);
			TrainSamp[i*WinX*WinY+j]=TempDouble;
		}
		fscanf(FP,"%d",&TempInt);
		TrainClass[i] = TempInt;
	}
	fclose(FP);
	TimeEnd = clock();
	printf("e-Time (Loading File): %f\n", (TimeEnd-TimeStart)/CLOCKS_PER_SEC);	
	
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\ThetaAndPOfHaarFeat_Node%s_3of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_ThetaP = fopen(StrTemp,"wt");
	if (FP_ThetaP==NULL) printf("File open error! (File for ThetaP)\n");
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\VMatForFFS_Node%s_3of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_VMat = fopen(StrTemp,"wt");
	if (FP_VMat==NULL) printf("File open error! (File for VMat)\n");

	for (k=0;k<NUM_HAARFEATS;k++)
	{

		Type = (unsigned char)HaarFeat[k*5+0];
		SizeX = HaarFeat[k*5+2];
		SizeY = HaarFeat[k*5+1];
		StartX = HaarFeat[k*5+4]-1;
		StartY = HaarFeat[k*5+3]-1;

		for (i=0;i<(nSampPos+nSampNeg);i++) {
			for (j=0;j<WinY*WinX;j++) {
				EachSamp[j] = TrainSamp[i*WinY*WinX+j];
			}
			TempDouble = RectFeatValueD(Type, SizeX, SizeY, StartX, StartY, EachSamp, WinX);
			FeatValues[i] = TempDouble;
		}

		double SumWpos=0,SumWneg=0,SP,SM;
		
		//for (i=0;i<(nSampPos+nSampNeg);i++) Idx[i]=i;
		for (i=0;i<nSampPos+nSampNeg;i++) {
			if (i<nSampPos) {
				W[i]= 1/(double)(2*nSampPos);
				SumWpos = SumWpos + W[i];
			}
			else {
				W[i]= 1/(double)(2*nSampNeg);
				SumWneg = SumWneg + W[i];
			}
		}

		//BobbleSort(FeatValues,SortedFeatValues,nSampPos+nSampNeg,Idx);
		for (i=0;i<(nSampPos+nSampNeg);i++) {
			DoubleNums[i].value = FeatValues[i];
			DoubleNums[i].index = i;
		}
		qsort(DoubleNums, nSampPos+nSampNeg, sizeof(CSL_DoubleToSort), CompareStruct);
		
		Errors1[0]=1; 	Errors2[0]=1;
		for (i=1;i<(nSampPos+nSampNeg);i++) {
			SP=0,	SM=0;
			for (j=0;j<i;j++) {
				TempInt = DoubleNums[j].index; //TempInt = Idx[j];
				if (TrainClass[TempInt]==1) {
					SP = SP + W[TempInt];
				}
				else {
					SM = SM + W[TempInt];
				}
			}
			Errors1[i]=SP+(SumWneg-SM);
			Errors2[i]=SM+(SumWpos-SP);
		}

		int MinIndex1=0, MinIndex2=0;
		double MinValue1=0, MinValue2=0;
		MinValue1=FindMin(Errors1,(nSampPos+nSampNeg),&MinIndex1);
		MinValue2=FindMin(Errors2,(nSampPos+nSampNeg),&MinIndex2);

		if (MinValue1<=MinValue2) {
			Polarity = 1;
			Threshold = FeatValues[MinIndex1];
		}
		else {
			Polarity = -1;
			Threshold = FeatValues[MinIndex2];
		}
		//printf("MinValue1: %lf (%d)\nMinValue2: %lf (%d)\n",MinValue1,MinIndex1,MinValue2,MinIndex2);
		
		fprintf(FP_ThetaP,"%f %d\n",Threshold,Polarity);
		
		nCorrect = 0;
		int EstClass = 0;
		for (i=0;i<(nSampPos+nSampNeg);i++) {
			for (j=0;j<WinY*WinX;j++) {
				EachSamp[j] = TrainSamp[i*WinY*WinX+j];
			}
			TempDouble = RectFeatValueD(Type, SizeX, SizeY, StartX, StartY, EachSamp, WinX);
			if (TempDouble*Polarity >= Threshold*Polarity) EstClass=1;
			else EstClass=0;
			fprintf(FP_VMat,"%d ",EstClass);
			if (EstClass==TrainClass[i]) nCorrect=nCorrect+1;
		}
		fprintf(FP_VMat,"\n");
		
		RecogRates = nCorrect/(double)(nSampPos+nSampNeg)*100;
		
		printf("HaarFeats: %d---------------\nThreshold: %lf, Polarity: %d\nRecogRates: %.2f\n",k+1,Threshold,Polarity,RecogRates);
	}
	fclose(FP_ThetaP);
	fclose(FP_VMat);

	TimeEndTotal = clock();
	printf("Total e-Time: %.3f\n",(TimeEndTotal-TimeStartTotal)/CLOCKS_PER_SEC);
		
	free(TrainSamp);
	free(TrainClass);
}

		
