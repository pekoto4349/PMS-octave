function [resp]=createmodel(numInputs,modelID,numOutputs)

          
warning off;

%numInputs='2';
%numOutputs='1';
%modelID='5';


%config.mat modelID workDir numInputs numOutputs inputData ascending overprovisioning

save config.mat numInputs modelID numOutputs;

workDir=['/models/',modelID];
savecommand=['save ',workDir,'/config.mat numInputs modelID numOutputs'];
eval(savecommand)

loadcommand=['inputData=csvread(''',workDir,'/inputfile.csv'')'];
eval(loadcommand)
%load inputfile.csv;
%inputData=inputfile;

  
%FIX NORMALIZE INPUTS, check orientation of columns, seems to be rows: input number, columns: data lines
%old code in normalize_data  script
%equivalent to mapminmax in this script normalization code (from line 211 approximately

%transform to normalize. OUTPUT SHOULD BE TRAINVER2 variable with rows: input number, columns: data lines

inputData=inputData';
[trainver1,ps]=normalize(inputData,-1,1,0);

save config.mat numInputs modelID ps;
savecommand=['save ',workDir,'/config.mat numInputs modelID numOutputs ps'];
eval(savecommand)

 %needed for eliminating Inf values because of mean absolute value metric
  sizetrain=size(trainver1)
  for zer1=1:sizetrain(1)
      for zer2=1:sizetrain(2)
        if trainver1(zer1,zer2)==0
          trainver1(zer1,zer2)=0.001;
        end
        
      end
  end

[trainver2,finalval]=subset(trainver1,1,1,0.2);



   
 
      
 
  [train,medval,val]=subset(trainver2,1,1,0.2,0.3)
  
  sizetrain2=size(train);
  sizemedval2=size(medval);
  sizeval2=size(val);
  num_inputs=str2num(numInputs); 

  for trainsetPercentage=1:0.2:1
    
    save setup namearray namearrayIndex trainsetPercentage
    
    %MAY NEED ESCAPE CHARACTER
    %FIX get from config file and create path
    %path=['./bestnets/',strtrim(namearray(namearrayIndex,1:end)),'_',num2str(trainsetPercentage),'\'];
    
    createdirCommand=['mkdir ',workDir,'/bestnets'];
    eval(createdirCommand)
    
    %sizeval2 does not change, same validation set 
    sizetrain2(2)=trainsetPercentage*sizetrain2(2)
    sizemedval2(2)=trainsetPercentage*sizemedval2(2)
    
    
    %extract p,t from train
    p=train(1:num_inputs,1:sizetrain2(2))
    t=train((num_inputs+1):sizetrain2(1),1:sizetrain2(2));

    %extract medvalyin, medvalyout from medval
    medvalyin=medval(1:num_inputs,1:sizemedval2(2));
    medvalyout=medval((num_inputs+1):sizemedval2(1),1:sizemedval2(2));

    %extract sample,valy from val
    sample=val(1:num_inputs,1:sizeval2(2));
    valy=val((num_inputs+1):sizeval2(1),1:sizeval2(2));

    valy=valy';

    
    %save elearnver2_time.mat p t medvalyin medvalyout sample valy ps
    
    path=workDir;
    %for this we do not care if it has the same name because the files are in different folders
    savecommand=['save ',path,'/elearnver2_time.mat p t medvalyin medvalyout sample valy ps']
    %savecommand=['save elearnver2_time.mat p t medvalyin medvalyout sample valy ps']
    eval(savecommand)
    
    indicator=1;
    savespergen=0;
    generation=0;
    %save indicator indicator savespergen
    savecommand=['save ',path,'/indicator indicator savespergen']
    eval(savecommand)
    
    %save generation generation
    savecommand=['save ',path,'/generation generation']
    eval(savecommand)


    %Define NN parameters (number of inputs, number of outputs, range, data file)

    %Pass data set


    %NEW---CREATE VECTORS FROM DATASET
    %load elearnver2_time.mat
    loadcommand=['load ',path,'/elearnver2_time.mat']
    eval(loadcommand)
    
    %Set working dir
    %workCommand=['cd ./',modelID];
    %eval(workCommand)
    pwd

    %through workspace?in matlab the two workspaces are separated
    echo off all
    silent_functions
    % Fitness function
    fitnessfcn = @nnscript;
    % Number of Variables
    nvars = 19;
    max_tfs=3;
    % Linear inequality constraints
    A = [];
    b = [];
    % Linear equality constraints
    Aeq = [];
    beq = [];
    % Bounds
    %lb = [3 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
    %ub = [10 13 13 13 13 13 13 13 13 13 13 8 8 8 8 8 8 8 8];
    LB=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
    UB=[10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10];
    %lb=[];
    %ub=[];
    % Nonlinear constraints
    nonlcon = [];
    % Start with default options
    %options = gaoptimset;
    % Modify some parameters

    %POPULATION SIZE IN SOME CASES (=2) CAUSES OCTAVE BUGS ..RHS etc.)
    options = gaoptimset('Generations' ,30,'PopulationSize',30);%3 replaced by max_tfs
    %NORMALIZATION GIA TA YPOLOIPA DIASTHMATA


    %options = gaoptimset(options,'StallTimeLimit' ,Inf);
    %options = gaoptimset(options,'Display' ,'off');
    % Run GA
    %[X,FVAL,REASON,OUTPUT,POPULATION,SCORES] = ga(fitnessFunction,nvars,Aineq,Bineq,Aeq,Beq,LB,UB,nonlconFunction);
    [x,fval,exitflag,output,population,scores] = ga(fitnessfcn,nvars,A,b,Aeq,beq,LB,UB,nonlcon,options);


    %load indicator;
    loadcommand=['load ',path,'/indicator']
    eval(loadcommand)
    path=[workDir,'/bestnets'];
    for i=1:(indicator-1)
    eval(['load -binary ',path,'/net',num2str(i)]); 
    end

   
    %load elearnver2_time.mat
    loadcommand=['load ',workDir,'/elearnver2_time.mat']
    eval(loadcommand)

   

                
    clear y y2 y1

    max_nets=indicator-1 %TO BE CHANGED EACH TIME  CHANGE
    
    if (max_nets>0)
    
      sample_index=1;
      samplesize=size(valy); %number of validation cases
      inputsize=size(sample);% inputsize(1) is the number of inputs
      max_samples=samplesize(1);
      iter=1;

      for iter=1:max_nets%gia ka8e net---na orizw to megisto me vash ta posa nets vgainoun apo to ga
          for sample_index=1:max_samples%megisto me vash ta deigmata   CHANGE        
          eval(['y(',num2str(sample_index),',',num2str(iter),')=sim(net',num2str(iter),',sample(1:inputsize(1),',num2str(sample_index),'));' ]); %CHANGE?TO 1:4
          sample_index=sample_index+1;   %%to y exei ta apotelesmata tou estimation
          end
          iter=iter+1;
      end


     
     
      valy=valy';
      y=y';

      valy=denormalize(valy,ps,-1,1,str2num(numInputs));
      %y=denormalize(y,ps,-1,1,2);
      
       for denormInd=1:max_nets
          %y includes outputs from all saved networks, its a (maxnets x validation size) array
          y(denormInd,1:max_samples)=denormalize(y(denormInd,1:max_samples),ps,-1,1,str2num(numInputs)); 
          denormInd=denormInd+1;
      end
      
      %%%%end of mapminmax


      valy=valy';
      y=y';

      %edw afairw apo ka8e sthlh tou pinaka twn estimations tis pragmatikes times
      %meta tha prepei gia ka8e stoixeio na diairw me to antistoixo twn real gia
      %na vgazw % apokliseis (kai meta pros8eseis klp)
      for j=1:max_nets
          %y1=dy=yest-yreal
          y1(1:max_samples,j)=y(1:max_samples,j)-valy;%----na yparxei hdh to valy  CHANGE NA GINEI MAX SAMPLES
          j=j+1;
      end

                  %HERE HAS THE PROBLEM              
          
                  
      j=1;
      sample_index=1;
      %extract percentage of error with regards to the real value
      for j=1:max_nets
          sample_index=1;
          % fuzout: estimated from fis output
          % out: real output 

          %RMSE(j) = norm(y(1:end,j) - valy)/sqrt(length(valy));
          %CVRMSE(j) = RMSE./mean(valy);

         for sample_index=1:max_samples       %CHANGE NA GINEI MAX SAMPLES
           y2(sample_index,j)=y1(sample_index,j)/abs(valy(sample_index));  %changed to abs
           sample_index=sample_index+1;
         end
         j=j+1;
        
      end

      %mean error for each ANN model in the validation cases
      mean_error_for_each_model_in_all_validation_cases=mean(abs(y2));

      %reverse y2 in order to have in each column each validation case
      %24 columns, with #rows=to the number of produced models
      y2rev=y2';

      %mean error from combining all produced models for each validation case
      mean_error_from_combination_of_all_models_for_each_validation=mean(y2rev);

      %min_RMSE=min(RMSE)
      %min_CVRMSE=min(CVRMSE)

      final=mean_error_from_combination_of_all_models_for_each_validation';
      overall_mean_error=mean(abs(final));

      %to y2rev einai h vash gia na melethsoume ta windows klp...alla an
      %pairnoume windows pairnoume ta idia montela ka8e fora?h apla ta 10 mesaia
      %px. olwn twn provlepsewn?

      %START OF EXPERIMENTS
      sorted=sort(y2rev);
      median_for_each_validation_case=median(sorted);
      mean_from_medians=mean(abs((median(sorted))'));

      sizes=size(sorted);

      number_of_models=sizes(1);

      half=number_of_models/2;
      %half=round(half)
      window_size=1;
      best_mean_windowed=1000;
      middle1=floor((number_of_models+1)/2);
      middle2=floor((number_of_models+2)/2);
      for window_size=1:middle1
          %window_size=5;
          for column=1:max_samples
             all_cases_windowed_answer(column)=mean(sorted(middle1-window_size+1:middle2+window_size-1,column)); 
          end
          all_cases_windowed_answer;
          overall_mean_windowed=mean(abs((all_cases_windowed_answer)'));
          if overall_mean_windowed<best_mean_windowed
              best_window=window_size;
              best_mean_windowed=overall_mean_windowed;
          end
      end

      
      

      %END OF EXPERIMENTS

      bestmean=min(mean_error_for_each_model_in_all_validation_cases)
      index=1;
      index_of_best=1;
      y2size=size(y2);
      for index=1:y2size(2)
          if bestmean==mean_error_for_each_model_in_all_validation_cases(index)
              index_of_best=index;
              
          end    
      end
      index_of_best
      %save dataforplots best_window best_mean_windowed mean_from_medians median_for_each_validation_case overall_mean_error final mean_error_from_combination_of_all_models_for_each_validation mean_error_for_each_model_in_all_validation_cases y2 savespergen bestmean index_of_best valy y 

      savecommand=['save ',workDir,'/dataforplots best_window best_mean_windowed mean_from_medians median_for_each_validation_case overall_mean_error final mean_error_from_combination_of_all_models_for_each_validation mean_error_for_each_model_in_all_validation_cases y2 savespergen bestmean index_of_best valy y'];
      eval(savecommand);
      
      savecommand2=['save -binary ',workDir,'/dataforplotsBIN best_window best_mean_windowed mean_from_medians median_for_each_validation_case overall_mean_error final mean_error_from_combination_of_all_models_for_each_validation mean_error_for_each_model_in_all_validation_cases y2 savespergen bestmean index_of_best valy y'];
      eval(savecommand2);
      
      
     
      
      %FIX change to be stored in /models so that it is accessible from nodered
      %copyCommand=['copyfile("',workDir,'/bestnets/net',num2str(index_of_best),'","./")']
      %eval(copyCommand);
      
      renameCommand=['rename ',workDir,'/bestnets/net',num2str(index_of_best),' ',workDir,'/bestmodel.mat']
      eval(renameCommand);
      
      loadcommand=['load ',workDir,'/bestmodel.mat'];
      %load bestmodel.mat
      eval(loadcommand)
      changeNet=['net=net', num2str(index_of_best),';'];
      eval(changeNet)
      savecommand=['save ',workDir,'/bestmodel.mat net']
      eval(savecommand); 
      
      %NEW SECTION WITH FINAL VALIDATION
      
            
      %1X83 valy2 is the final final validation set
      
      
      sizeval3=size(finalval);
       finalsample=finalval(1:num_inputs,1:sizeval3(2));
       valyfin=finalval((num_inputs+1):sizeval3(1),1:sizeval3(2));
       
       valyfin=denormalize(valyfin,ps,-1,1,str2num(numInputs));
       valyfin=valyfin';
       samplesize2=size(valyfin); %number of validation cases
       
       max_final_samples=samplesize2(1);
       whos
       for final_sample_index=1:max_final_samples       %CHANGE NA GINEI MAX final SAMPLES, inputsize does not change it is the numInputs
          % eval(['yfin(',num2str(final_sample_index),',1)=sim(net,finalsample(1:inputsize(1),num2str(final_sample_index),'));' ]); %CHANGE?TO 1:4   
           eval(['yfin(',num2str(final_sample_index),',1)=sim(net,finalsample(1:inputsize(1),',num2str(final_sample_index),'));' ]); %CHANGE?TO 1:4
          %eval(['y(',num2str(sample_index),',',num2str(iter),')=sim(net',num2str(iter),',sample(1:inputsize(1),',num2str(sample_index),'));' ]); %CHANGE?TO 1:4
          
           
           final_sample_index=final_sample_index+1;
       end
      
      %finalval=finalval';
       %finalval=denormalize(finalval,ps,-1,1,str2num(numInputs));
       
       
       %valy2 is the denormalized output of the final final validation set
       yfin=yfin';
       yfin=denormalize(yfin,ps,-1,1,str2num(numInputs));
       
       
       %y3 is the predicted output in the final final validation set of the best model
       
       yfin=yfin';
       
       max_final_samples=samplesize2(1);
       
       
       y1fin(1:max_final_samples,1)=yfin(1:max_final_samples,1)-valyfin;
       
       for final_sample_index=1:max_final_samples 
          y2fin(final_sample_index,1)=y1fin(final_sample_index,1)/abs(valyfin(final_sample_index));  %changed to abs
          final_sample_index=final_sample_index+1;
       end
         
       
      
       %this is not needed here, since we only have the best net
%       for denormInd=1:max_nets
%          %y includes outputs from all saved networks, its a (maxnets x validation size) array
%          y(denormInd,1:max_samples)=denormalize(y(denormInd,1:max_samples),ps,-1,1,str2num(numInputs)); 
%          denormInd=denormInd+1;
%      end
      
      subplot(2,2,1);
      plot(mean_error_for_each_model_in_all_validation_cases*100);
      title("MAPE of Candidate Models in \n Intermediate Validation Set");
      xlabel("Model#");
      ylabel("MAPE %");
      subplot(2,2,2);
      plot(y2(1:end,index_of_best)*100);
      title("%Error Per Intermediate \nValidation Case(Best Model)");
      xlabel("Validation Case");
      ylabel("%Error");
      subplot(2,2,3);
      bar(mean_error_for_each_model_in_all_validation_cases*100);
      axis("tic[y]");
      legend("Saved Models Evolution of \nIntermediate MAPE","location", "northwest");
      % xlabel("Model#");
      ylabel("MAPE %");
      subplot(2,2,4);
      plot(y2fin(1:end)*100);
       xlabel("Final Validation Case");
      ylabel("% Error per final validation case");
      score=mean(abs(y2fin))*100;
      scorestring=['Final validation MAPE:',num2str(score),'%'];
      legend(scorestring,"location", "northwest");
      disp("Keeping best model...")
      printcommand=['print -djpg /models/images/',modelID,'.jpg'];
      eval(printcommand);
     
     printcommand=['csvwrite(''/models/',modelID,'/quality.txt'',score)'];
      eval(printcommand);
     
     end %end of if no networks have been saved 
    
  end

  

x = -1:0.05:1; y = -1:0.05:1;
k=1;
z=[0;0;0]';
for i=1:length(x)
  for j=1:length(x)
    
    out=sim(net,[x(i);y(j)]);
    x(i);
    y(j);
    z1=[x(i);y(j);out]';
    z=[z;z1];
    k=k+1;
   endfor
  endfor
  z=z(2:end,1:end);
  x1=z(1:end,1);
  y1=z(1:end,2);
  z1=z(1:end,3);
  plot3(x1,y1,z1)
  
clf;
 scatter3 (x1(:), y1(:), z1(:), [], z1(:));
xlabel('Input 1')
ylabel('Input 2')
zlabel('Output')
 %NEED DENORMALIZATION FOR OUTPUTS- saving fig and image in /models
 %AUtomatic addition of axis titles probably needing new arguments in octave script
 %CHECK IF WE CAN ROTATE IN UI
 
printcommand=['print -dsvg /models/images/',modelID,'.svg'];
      eval(printcommand);

%      printcommand=['hgsave(h,"/models/images/',modelID,'")'];
%      eval(printcommand);
%    hgsave(h,"figure");   
  %save program_end program_end
  
endfunction
