#include <iostream>
#include <time.h>

#define		NUM_HAARFEATS1			5870
#define		NUM_HAARFEATS2			5870
#define		NUM_HAARFEATS3			5870
#define		NUM_HAARFEATS4			5870
#define		NUM_HAARFEATS			23480
#define		nSampPos				2800
#define		nSampNeg				2800
#define		MAX_NUM_HAARFEATS		500

char ExperimentsIndex[] = "04";
char NodeIndex[] = "08";

void main()
{
	int *VMat, *HaarFeats, *TargetVec, *VPrimeVec, *Polarities, *TrainClass, *ResultsOfBestHaarFeats;
	int i, j, k, t, TempInt, nTrain, theta, nCorrect, IndexOfBestFeat, ThetaOfBestFeat, EstClass, EnsenbleTheta=0;
	double *Thresholds, TempDouble, RecogRates, MaxRecogRates, MaxRecogRatesTotal, TimeStart, TimeEnd;
	char StrTemp[500];
	char FileName1[] = "HaarFeatsSelectedByFFS";
	char FileName2[] = "OutPutOfHaarFeatsSelectedByFFS";
	char FileName3[] = "ThresholdsOfHaarFeatsSelectedByFFS";
	
	nTrain = nSampPos + nSampNeg;

	VMat = (int*)malloc(sizeof(int)*NUM_HAARFEATS*nTrain);
	TargetVec = (int*)malloc(sizeof(int)*nTrain);
	ResultsOfBestHaarFeats = (int*)malloc(sizeof(int)*nTrain);
	VPrimeVec = (int*)malloc(sizeof(int)*nTrain);
	TrainClass = (int*)malloc(sizeof(int)*nTrain);

	Thresholds = (double*)malloc(sizeof(double)*NUM_HAARFEATS);
	Polarities = (int*)malloc(sizeof(int)*NUM_HAARFEATS);
	HaarFeats = (int*)malloc(sizeof(int)*NUM_HAARFEATS*5);
	
	printf("Loading Data Files...\n");
	TimeStart = clock();
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\VMatForFFS_Node%s_1of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_VMat1 = fopen(StrTemp,"rt");
	if (FP_VMat1==NULL) printf("File open error! (File for VMat1)\n");
	for (i=0;i<NUM_HAARFEATS1;i++) {
		for (j=0;j<nTrain;j++) {
			fscanf(FP_VMat1,"%d",&TempInt);
			VMat[i*nTrain+j] = TempInt;
		}
	}
	fclose(FP_VMat1);

	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\VMatForFFS_Node%s_2of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_VMat2 = fopen(StrTemp,"rt");
	if (FP_VMat2==NULL) printf("File open error! (File for VMat2)\n");
	for (i=NUM_HAARFEATS1;i<(NUM_HAARFEATS1+NUM_HAARFEATS2);i++) {
		for (j=0;j<nTrain;j++) {
			fscanf(FP_VMat2,"%d",&TempInt);
			VMat[i*nTrain+j] = TempInt;
		}
	}
	fclose(FP_VMat2);

	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\VMatForFFS_Node%s_3of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_VMat3 = fopen(StrTemp,"rt");
	if (FP_VMat3==NULL) printf("File open error! (File for VMat3)\n");
	for (i=(NUM_HAARFEATS1+NUM_HAARFEATS2);i<(NUM_HAARFEATS1+NUM_HAARFEATS2+NUM_HAARFEATS3);i++) {
		for (j=0;j<nTrain;j++) {
			fscanf(FP_VMat3,"%d",&TempInt);
			VMat[i*nTrain+j] = TempInt;
		}
	}
	fclose(FP_VMat3);

	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\VMatForFFS_Node%s_4of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_VMat4 = fopen(StrTemp,"rt");
	if (FP_VMat4==NULL) printf("File open error! (File for VMat4)\n");
	for (i=(NUM_HAARFEATS1+NUM_HAARFEATS2+NUM_HAARFEATS3);i<(NUM_HAARFEATS1+NUM_HAARFEATS2+NUM_HAARFEATS3+NUM_HAARFEATS4);i++) {
		for (j=0;j<nTrain;j++) {
			fscanf(FP_VMat4,"%d",&TempInt);
			VMat[i*nTrain+j] = TempInt;
		}
	}
	fclose(FP_VMat4);

	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\ThetaAndPOfHaarFeat_Node%s_1of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_ThetaP1 = fopen(StrTemp,"rt");
	if (FP_ThetaP1==NULL) printf("File open error! (File for ThetaP1)\n");
	for (i=0;i<NUM_HAARFEATS1;i++) {
		fscanf(FP_ThetaP1,"%lf",&TempDouble);
		Thresholds[i] = TempDouble;
		fscanf(FP_ThetaP1,"%d",&TempInt);
		Polarities[i] = TempInt;
	}
	fclose(FP_ThetaP1);

	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\ThetaAndPOfHaarFeat_Node%s_2of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_ThetaP2 = fopen(StrTemp,"rt");
	if (FP_ThetaP2==NULL) printf("File open error! (File for ThetaP2)\n");;
	for (i=NUM_HAARFEATS1;i<(NUM_HAARFEATS1+NUM_HAARFEATS2);i++) {
		fscanf(FP_ThetaP2,"%lf",&TempDouble);
		Thresholds[i] = TempDouble;
		fscanf(FP_ThetaP2,"%d",&TempInt);
		Polarities[i] = TempInt;
	}
	fclose(FP_ThetaP2);
	
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\ThetaAndPOfHaarFeat_Node%s_3of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_ThetaP3 = fopen(StrTemp,"rt");
	if (FP_ThetaP3==NULL) printf("File open error! (File for ThetaP3)\n");
	for (i=(NUM_HAARFEATS1+NUM_HAARFEATS2);i<(NUM_HAARFEATS1+NUM_HAARFEATS2+NUM_HAARFEATS3);i++) {
		fscanf(FP_ThetaP3,"%lf",&TempDouble);
		Thresholds[i] = TempDouble;
		fscanf(FP_ThetaP3,"%d",&TempInt);
		Polarities[i] = TempInt;
	}
	fclose(FP_ThetaP3);

	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\ThetaAndPOfHaarFeat_Node%s_4of4.dat",ExperimentsIndex,NodeIndex,NodeIndex);
	FILE *FP_ThetaP4 = fopen(StrTemp,"rt");
	if (FP_ThetaP4==NULL) printf("File open error! (File for ThetaP4)\n");
	for (i=(NUM_HAARFEATS1+NUM_HAARFEATS2+NUM_HAARFEATS3);i<(NUM_HAARFEATS1+NUM_HAARFEATS2+NUM_HAARFEATS3+NUM_HAARFEATS4);i++) {
		fscanf(FP_ThetaP4,"%lf",&TempDouble);
		Thresholds[i] = TempDouble;
		fscanf(FP_ThetaP4,"%d",&TempInt);
		Polarities[i] = TempInt;
	}
	fclose(FP_ThetaP4);

	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\HaarFeatInfo18x18.dat",ExperimentsIndex);
	FILE *FP_Haar = fopen(StrTemp,"rt");
	if (FP_Haar==NULL) printf("File open error! (File for Haar)\n");
	for (i=0;i<5*NUM_HAARFEATS;i++) {
		fscanf(FP_Haar,"%d",&TempInt);
		HaarFeats[i] = TempInt;
	}
	fclose(FP_Haar);

	TimeEnd = clock();
	printf("e-Time for data loading : %lf\n",(TimeEnd-TimeStart)/CLOCKS_PER_SEC);

	for (i=0;i<nSampPos;i++) TrainClass[i]=1;
	for (i=nSampPos;i<nTrain;i++) TrainClass[i]=0;
	for (i=0;i<nTrain;i++) TargetVec[i]=0;
	
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\%s_Node%s.dat",ExperimentsIndex,NodeIndex,FileName1,NodeIndex);
	FILE *FP_HaarFeats = fopen(StrTemp,"wt");
	fprintf(FP_HaarFeats,"Type   SizeY   SizeX   StartY   StartX   Polarity\n");
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\%s_Node%s.dat",ExperimentsIndex,NodeIndex,FileName2,NodeIndex);
	FILE *FP_FeatOutPut = fopen(StrTemp,"wt");
	sprintf(StrTemp,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Training\\%s_Node%s.dat",ExperimentsIndex,NodeIndex,FileName3,NodeIndex);
	FILE *FP_Thresholds = fopen(StrTemp,"wt");

	MaxRecogRates = 0;
	MaxRecogRatesTotal = 0;	
	
	for (k=0;k<MAX_NUM_HAARFEATS;k++) {

		TimeStart = clock();
		
		for (i=0;i<NUM_HAARFEATS;i++) {

			if (k==0) {
				theta = 1;
				nCorrect=0;
				for (j=0;j<nTrain;j++) {
					VPrimeVec[j] = TargetVec[j] + VMat[i*nTrain+j];

					if (VPrimeVec[j]>=theta) EstClass=1;
					else EstClass=0;
					
					if (EstClass==TrainClass[j]) nCorrect=nCorrect+1;
				}
				RecogRates = nCorrect/(double)nTrain*100;

				if (RecogRates>MaxRecogRates) {
					MaxRecogRates = RecogRates;
					IndexOfBestFeat = i;
					ThetaOfBestFeat = theta;
					for (j=0;j<nTrain;j++) 	ResultsOfBestHaarFeats[j] = VMat[i*nTrain+j];
				}				
			}
			else {
				//printf("theta=%d\n",theta);
				for(t=EnsenbleTheta-2;t<=EnsenbleTheta+2;t++) {
					theta = t;			

					nCorrect=0;
					for (j=0;j<nTrain;j++) {
						VPrimeVec[j] = TargetVec[j] + VMat[i*nTrain+j];

						if (VPrimeVec[j]>=theta) EstClass=1;
						else EstClass=0;
						
						if (EstClass==TrainClass[j]) nCorrect=nCorrect+1;
					}
					RecogRates = nCorrect/(double)nTrain*100;

					if (RecogRates>MaxRecogRates) {
						MaxRecogRates = RecogRates;
						IndexOfBestFeat = i;
						ThetaOfBestFeat = theta;
						for (j=0;j<nTrain;j++) 	ResultsOfBestHaarFeats[j] = VMat[i*nTrain+j];
					}
				}
			}
		}
		
		TimeEnd = clock();
		printf("Selection for Feat. # %d\n",k+1);
		printf("RecogRates = %f (%f)\n",MaxRecogRates,(TimeEnd-TimeStart)/CLOCKS_PER_SEC);

		if ((k==1) || (MaxRecogRates > MaxRecogRatesTotal)) {
			MaxRecogRatesTotal = MaxRecogRates;
			EnsenbleTheta = ThetaOfBestFeat;

			for (j=0;j<nTrain;j++) {
				fprintf(FP_FeatOutPut,"%d ",ResultsOfBestHaarFeats[j]);
				TargetVec[j] = TargetVec[j] + ResultsOfBestHaarFeats[j];
			}
			fprintf(FP_FeatOutPut,"\n");

			for (j=0;j<5;j++) fprintf(FP_HaarFeats,"%d, ",HaarFeats[IndexOfBestFeat*5+j]);
			fprintf(FP_HaarFeats,"%d,\n",Polarities[IndexOfBestFeat],Thresholds[IndexOfBestFeat],EnsenbleTheta);
			fprintf(FP_Thresholds,"%lf,	",Thresholds[IndexOfBestFeat]);
			
		}
		else {
			printf("Selection is over! k=%d\n",k+1);
			break;
		}
	}	

	fclose(FP_HaarFeats);
	fclose(FP_FeatOutPut);
	fclose(FP_Thresholds);

	free(VMat);
	free(TargetVec);
	free(VPrimeVec);
	free(Thresholds);
	free(Polarities);
	free(ResultsOfBestHaarFeats);
	free(TrainClass);
	free(HaarFeats);
	
}
