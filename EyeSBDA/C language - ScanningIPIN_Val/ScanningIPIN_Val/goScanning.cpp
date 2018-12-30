#include <iostream>
#include <io.h>
#include <math.h>
#include <time.h>

#include "ScanningFunction.h"

#define		NUM_IMAGES					1400
#define		MIN_IMAGE_SIZE				18
#define		WIN_SIZE					18

#define		PRINT_UNIT_FALPOS			1
#define		FLAG_TOTAL					0
#define		PRINT_UNIT_TOTALTRUEPOS		1
#define		PRINT_UNIT_TOTALFALPOS		1
#define		FLAG_REMAINS				1
#define		NumOfNode					1

char ExperimentStr[] = "05";
char NodeStr[] = "00";
//Validation

void main()
{	
	char *FileName, pathImages[500], pathOutput1[500], pathOutput2[500], StrTemp[400];
	unsigned int ImageIndex=0, NodeIndex=0, nImages, count;
	long ImgHeight, ImgWidth, ImgWidth4, ImgHeightNew, ImgWidthNew, ImgHeightLevel, ImgWidthLevel, x, y, lx, ly, rx, ry;
	unsigned char *ImgMat, *ImgMatDown, *ImgMatLevel;
	long long *ImgMatIntgSq, *ImgMatIntg;
	int i,j,Flag, nLevel, nPatch, nPos, nNeg, nTruePos, nTrueNeg, nFalsePos, nFalseNeg, nPatchRemain, nPatchLevel, nPatchReject;
	int TrueClass, EstClass, EyeCoordY, EyeCoordX, LeftTopY, LeftTopX, RightBottomY, RightBottomX, TempInt;
	double Dist1, Dist2, Dist3, PatchScore1, PatchScore2, TimeStart, TimeEnd, Time=0,TempDouble, Distance;
	float ScaleFactor=0.8;

	CSL_StrongClassifierBDA NodeClassifier[NumOfNode];
	CSL_ImgPatch Patch;

	LoadingNodeClassifierINBDA(NodeClassifier,NumOfNode,1);

	printf("Scanning Test Images\n");
	sprintf(pathImages,"D:\\EyeSBDA\\Images-Validation\\");
	sprintf(pathOutput1,"D:\\EyeSBDA\\Experiments%s\\Cascade-LAC\\Node%s\\Validation\\",ExperimentStr,NodeStr);
	sprintf(pathOutput2,"ResultsOfScanningLAC\\");
	
	nImages = NUM_IMAGES;

	FILE *FP_EyeCoord;
	sprintf(StrTemp,"D:\\EyeSBDA\\Val_Eye_Coord.dat");
	FP_EyeCoord = fopen(StrTemp,"rt");
	if (FP_EyeCoord==NULL) printf("File open error! (File for EyeCoord)\n");
	
	FILE *FP_TotalTP, *FP_TotalFP;
	if (FLAG_TOTAL==1)
	{
		sprintf(StrTemp,"%s\\Total_TP_Node%s.dat",pathOutput1,NodeStr);
		FP_TotalTP = fopen(StrTemp,"wt");
		if (FP_TotalTP==NULL) printf("File open error! (File for Total TP)\n");

		sprintf(StrTemp,"%s\\Total_FP_Node%s.dat",pathOutput1,NodeStr);
		FP_TotalFP = fopen(StrTemp,"wt");
		if (FP_TotalFP==NULL) printf("File open error! (File for Total FP)\n");
	}
	
	sprintf(StrTemp,"%s\\ScanningResultsofLACToNode%s.dat",pathOutput1,NodeStr);
	FILE *FP_Results = fopen(StrTemp,"wt");
	if (FP_Results==NULL) printf("File open error! (File for Results)\n");
	
	int nTotalFalsePos=0, nTotalTruePos=0, nImages0TruePos=0, nImagesRemains0=0, nRealTotalFalsePos=0;
	FILE *FP_Remain;

	_finddatai64_t c_file;
	intptr_t hFile;
	
	char Ext[] = "*.bmp";
	sprintf(StrTemp,"%s%s",pathImages,Ext);
	hFile = _findfirsti64(StrTemp,&c_file);
	do {

		TimeStart = clock();

		FileName = c_file.name;

		sprintf(StrTemp,"%s\\%sLAC_TP_%s_%s.dat",pathOutput1,pathOutput2,NodeStr,c_file.name);				
		FILE *FP_TP = fopen(StrTemp,"wt");
		if (FP_TP==NULL) printf("File open error! (File for TP)\n");
		
		sprintf(StrTemp,"%s\\%sLAC_FP_%s_%s.dat",pathOutput1,pathOutput2,NodeStr,c_file.name);		
		FILE *FP_FP = fopen(StrTemp,"wt");
		if (FP_FP==NULL) printf("File open error! (File for FP)\n");

		if (FLAG_REMAINS==1){
			sprintf(StrTemp,"%s\\%sLAC_RemainingPatches_%s_%s.dat",pathOutput1,pathOutput2,NodeStr,c_file.name);
			FP_Remain = fopen(StrTemp,"wt");
			if (FP_Remain==NULL) printf("File open error! (File for Remaining Patches)\n");
		}
		sprintf(StrTemp,"%s%s",pathImages,c_file.name);
		ReadSizeOfGrayBMP(StrTemp,&ImgHeight,&ImgWidth);
		ImgWidth4 = ((ImgWidth-1)/4+1)*4;
		if (ImgWidth4==ImgWidth) printf("Training Image:%d ->%s (%dx%d)\n",ImageIndex+1,FileName,ImgWidth,ImgHeight);
		else printf("Training Image:%d ->%s (%dx%d);(%dx%d)\n",ImageIndex+1,FileName,ImgWidth,ImgHeight,ImgWidth4,ImgHeight);

		if ((ImgWidth>MIN_IMAGE_SIZE)&&(ImgHeight>MIN_IMAGE_SIZE)) Flag=0;
		else Flag=1;
		ImgMat = (unsigned char*)malloc(sizeof(unsigned char)*ImgWidth4*ImgHeight);
		LoadingGrayBMP(StrTemp,ImgMat);

		fscanf(FP_EyeCoord,"%d",&TempInt);
		EyeCoordY = TempInt+1;
		fscanf(FP_EyeCoord,"%d",&TempInt);
		EyeCoordX = TempInt+1;
		fscanf(FP_EyeCoord,"%lf",&TempDouble);
		Distance = TempDouble;
		LeftTopY = EyeCoordY - Distance/2;
		LeftTopX = EyeCoordX - Distance/2;
		RightBottomY = EyeCoordY + Distance/2;
		RightBottomX = EyeCoordX + Distance/2;
		
		LeftTopY = (LeftTopY<1?1:LeftTopY);
		LeftTopX = (LeftTopX<1?1:LeftTopX);
		RightBottomY = (RightBottomY>ImgHeight?ImgHeight:RightBottomY);
		RightBottomX = (RightBottomX>ImgWidth?ImgWidth:RightBottomX);

		nPatch = 0;
		nNeg = 0;		
		nTrueNeg = 0;
		nFalsePos = 0;
		nFalseNeg = 0;
		nPatchRemain = 0;
		nLevel = 0;
		nPos = 0;
		nTruePos = 0;	
		nPatchReject = 0;
		ImgWidthLevel = ImgWidth;
		ImgHeightLevel = ImgHeight;
		while (Flag==0)
		{
			ImgMatLevel = (unsigned char*)malloc(sizeof(unsigned char)*ImgWidthLevel*ImgHeightLevel);
			if (nLevel==0)
			{
				for (i=0;i<ImgHeightLevel;i++)
				{
					for (j=0;j<ImgWidthLevel;j++)
					{
						ImgMatLevel[i*ImgWidthLevel+j] = ImgMat[i*ImgWidth4+j];
					}
				}
			}
			else
			{ 
				for (i=0;i<ImgHeightLevel;i++)
				{
					for (j=0;j<ImgWidthLevel;j++)
					{
						ImgMatLevel[i*ImgWidthLevel+j] = ImgMatDown[i*ImgWidthLevel+j];
					}
				}				
				free(ImgMatDown);
			}
			ImgMatIntg = (long long*)malloc(sizeof(long long)*ImgWidthLevel*ImgHeightLevel);
			ImgMatIntgSq = (long long*)malloc(sizeof(long long)*ImgWidthLevel*ImgHeightLevel);
			
			IntgImg(ImgMatLevel,ImgMatIntg,ImgHeightLevel,ImgWidthLevel);
			IntgSqImg(ImgMatLevel,ImgMatIntgSq,ImgHeightLevel,ImgWidthLevel);
			
			nPatchLevel = 0;
			
			for (i=0;i<ImgHeightLevel-WIN_SIZE+1;i++)
			{
				for (j=0;j<ImgWidthLevel-WIN_SIZE+1;j++)
				{
					nPatchLevel = nPatchLevel + 1;
					LoadingImgPatch(&Patch,WIN_SIZE,WIN_SIZE,j,i);
					MeanStdImgPatch(&Patch,ImgMatIntg,ImgMatIntgSq,ImgWidthLevel);
										
					x = (long)((j+WIN_SIZE/2+1)*(ImgWidth/(double)ImgWidthLevel)+0.5);
					y = (long)((i+WIN_SIZE/2+1)*(ImgHeight/(double)ImgHeightLevel)+0.5);
					lx = (long)((j+1)*(ImgWidth/(double)ImgWidthLevel)+0.5);
					ly = (long)((i+1)*(ImgHeight/(double)ImgHeightLevel)+0.5);
					rx = (long)((j+WIN_SIZE+1)*(ImgWidth/(double)ImgWidthLevel)+0.5);
					ry = (long)((i+WIN_SIZE+1)*(ImgHeight/(double)ImgHeightLevel)+0.5);

					Dist1 = sqrt( (double)((EyeCoordX-x)*(EyeCoordX-x)+(EyeCoordY-y)*(EyeCoordY-y)) );
					Dist2 = sqrt( (double)((LeftTopX-lx)*(LeftTopX-lx)+(LeftTopY-ly)*(LeftTopY-ly)) );
					Dist3 = sqrt( (double)((RightBottomX-rx)*(RightBottomX-rx)+(RightBottomY-ry)*(RightBottomY-ry)) );

					PatchScore1 = (double)Dist1/(double)Distance;
					PatchScore2 = (Dist2>Dist3?Dist2:Dist3)/(RightBottomX-LeftTopX);

					if (PatchScore1 <= 0.125)
					{
						nPos = nPos + 1;
						TrueClass = 1;
					}
					else if ( (PatchScore1 >= 0.5) || (PatchScore2 >= 0.5) )
					{
						nNeg = nNeg + 1;
						TrueClass = 0;
					}
					else TrueClass = -1;

					NodeIndex = 1;
					EstClass = 1;
					count = 1;
					
					while ( (NodeIndex < NumOfNode) && (EstClass == 1) )
					{
						EstClass = NodeClassificationINBDA(NodeClassifier,NodeIndex,ImgMatIntg,ImgWidthLevel,&Patch,&count);
						NodeIndex = NodeIndex + 1;
					}
					
					if (EstClass==0) nPatchReject = nPatchReject + 1;
					if ((EstClass==1)&&(FLAG_REMAINS==1)) fprintf(FP_Remain,"%d, %d, %d, %d, %d, %d, %f, %d\n",ImgWidthLevel,ImgHeightLevel,j+1,i+1,(j+WIN_SIZE),(i+WIN_SIZE),PatchScore1,count);
					
					if ((EstClass==1) && (TrueClass==0))
					{
						nPatchRemain = nPatchRemain + 1;
						nFalsePos = nFalsePos + 1;
						nTotalFalsePos = nTotalFalsePos + 1;
						nRealTotalFalsePos = nRealTotalFalsePos + 1;
						
						if (nFalsePos%PRINT_UNIT_FALPOS==0)
						{
							fprintf(FP_FP,"%d, %d, %d, %d, %d, %d, %f, %d\n",ImgWidthLevel,ImgHeightLevel,j+1,i+1,(j+WIN_SIZE),(i+WIN_SIZE),PatchScore1,count);
						}
						if ((FLAG_TOTAL==1) && (nTotalFalsePos%PRINT_UNIT_TOTALFALPOS==0))
						{
							fprintf(FP_TotalFP,"%d, %d, %d, %d, %d, %d, %d, %f, %d\n",ImageIndex+1,ImgWidthLevel,ImgHeightLevel,j+1,i+1,(j+WIN_SIZE),(i+WIN_SIZE),PatchScore1,count);
						}

					}
					else if ((EstClass==0) && (TrueClass==1))
					{
						nFalseNeg = nFalseNeg + 1;
					}
					else if ((EstClass==1) && (TrueClass==1))
					{
						nPatchRemain = nPatchRemain + 1;
						nTruePos = nTruePos + 1;
						nTotalTruePos = nTotalTruePos + 1;

						fprintf(FP_TP,"%d, %d, %d, %d, %d, %d, %f, %d\n",ImgWidthLevel,ImgHeightLevel,j+1,i+1,(j+WIN_SIZE),(i+WIN_SIZE),PatchScore1,count);

						if ((FLAG_TOTAL==1) && (nTotalTruePos%PRINT_UNIT_TOTALTRUEPOS==0))
						{
							fprintf(FP_TotalTP,"%d, %d, %d, %d, %d, %d, %d, %f, %d\n",ImageIndex+1,ImgWidthLevel,ImgHeightLevel,j+1,i+1,(j+WIN_SIZE),(i+WIN_SIZE),PatchScore1,count);
						}
					}
					else if ((EstClass==0) && (TrueClass==0))
					{
						nTrueNeg = nTrueNeg + 1;
					}
					else if ((EstClass==1) && (TrueClass==-1))
					{
						
						if ( (PatchScore1 >= 0.5) || (PatchScore2 >= 0.5) )
						{
							nPatchRemain = nPatchRemain + 1;
							nFalsePos = nFalsePos + 1;
							nTotalFalsePos = nTotalFalsePos + 1;
						}
					}
					else if ((EstClass==0) && (TrueClass==-1))
					{
						nTrueNeg = nTrueNeg + 1;
					}
				}
			}

			free(ImgMatIntg);
			free(ImgMatIntgSq);

			ImgHeightNew = (long)(ImgHeightLevel*ScaleFactor+0.5);
			ImgWidthNew = (long)(ImgWidthLevel*ScaleFactor+0.5);

			if ( (ImgHeightNew<MIN_IMAGE_SIZE)||(ImgWidthNew<MIN_IMAGE_SIZE) ) 
			{
				Flag=1;
				free(ImgMatLevel);
			}
			else
			{
				nLevel = nLevel + 1;
				
				ImgMatDown = (unsigned char*)malloc(sizeof(unsigned char)*ImgWidthNew*ImgHeightNew);
				ImageScaleDown(ImgMatLevel,ImgHeightLevel,ImgWidthLevel,ImgMatDown,ScaleFactor);
				free(ImgMatLevel);
				
				ImgWidthLevel = ImgWidthNew;
				ImgHeightLevel = ImgHeightNew;
			}
		}
		free(ImgMat);

		fclose(FP_TP);
		fclose(FP_FP);
		
		if (nTruePos==0)
		{
			fprintf(FP_Results,"%s has no remaining True positives (nPos=%d)\n",FileName,nPos);
			nImages0TruePos=nImages0TruePos+1;
		}
		else if (nTruePos<=5) fprintf(FP_Results,"%s has %d true positives (nPos=%d)\n",FileName,nTruePos,nPos);
		
		if (FLAG_REMAINS==1) fclose(FP_Remain);
		
		if (nPatchRemain==0)
		{
			fprintf(FP_Results,"%s has no remaining image patches\n",FileName);
			nImagesRemains0=nImagesRemains0+1;
		}
		if (nFalsePos==0)
		{
			fprintf(FP_Results,"%s has no false positives\n",FileName);
			printf("%s has no false positives\n",FileName);
		}
		
		printf("Num. of the remaining true positives : %d(%d)\n",nTruePos,nPos);
		printf("Num. of the remaining false positives : %d\n",nFalsePos);
		printf("Num. of remaining patches : %d\n",nPatchRemain);
		printf("Num. of the rejected patches : %d\n",nPatchReject);

		TimeEnd = clock();
		Time += (TimeEnd-TimeStart)/CLOCKS_PER_SEC;

		ImageIndex = ImageIndex + 1;
		
	} while(_findnexti64(hFile,&c_file)==0 && (ImageIndex<nImages));

	Time = Time / nImages;
	printf("MeanTime : %f\n", Time);

	printf("Num. of Images have no true positives : %d\n",nImages0TruePos);
	printf("Num. of Images have no remaining image patches : %d\n",nImagesRemains0);
	printf("Total Num. of False Positives : %d / %d\n",nTotalFalsePos,nRealTotalFalsePos);
	printf("Total Num. of True Positives : %d\n",nTotalTruePos);
	
	fprintf(FP_Results,"Num. of Images have no true positives : %d\n",nImages0TruePos);
	fprintf(FP_Results,"Total Num. of True Positives : %d\n",nTotalTruePos);
	fprintf(FP_Results,"Total Num. of False Positives : %d\n",nTotalFalsePos);
	fclose(FP_Results);
	fclose(FP_EyeCoord);
	
	if (FLAG_TOTAL==1)
	{
		fclose(FP_TotalFP);
		fclose(FP_TotalTP);
	}
}