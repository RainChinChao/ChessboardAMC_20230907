% PXA N9030B IQ file extractor
% v0.1 EAB 23/9/21
clc;
close all;
%clear all;

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% enter the file path to be read here....
IQfile = 'C:\Users\elx22yz\Desktop\Data\28GHz IQ capture files 30_9_21\qam16 cond.csv';
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


delimiter = ',';
opts = delimitedTextImportOptions('Delimiter',delimiter); 
samples = readmatrix(IQfile, opts);

% strip off text etc at start and just get IQIQIQIQIQ..
%IQsamples = samples(10:length(samples));
IQsamples = samples((10:length(samples)),1);

% extract key info about capture
centre_frequency = str2double(samples(5,2)); % Hz
capture_BW = str2double(samples(7,2)); % Hz
capture_duration = str2double(samples(8,2)); % seconds
% does not seem to save the actual sample rate used...

% convert to number array 
IQsamples = str2double(IQsamples);

%figure(1)
%plot(IQsamples);
%title 'Captured time domain samples in IQIQIQIQIQ...';

% extract to I-Q pairs as a complex number
IQ_final_samples = [];
k = 1;
r = 1;
while (k<=(length(IQsamples)-1))
    IQ_final_samples(r) = IQsamples(k) + j*IQsamples(k+1);
    k = k+2;
    r = r+1;
end

%figure(2)
%plot(real(IQ_final_samples), imag(IQ_final_samples));
%title 'IQ samples converted to complex samples';
%xlabel 'real';
%ylabel 'imag';

% save key data
%save IQsamples.mat IQ_final_samples centre_frequency capture_BW capture_duration;








sample_count_2PSK=0;
sample_count_4PSK=0;
sample_count_8PSK=0;
sample_count_16QAM=0;

import_signal_no=20;
XY_scale=5;
XY_length=10;
grid_scale=0.1;

sample_no1=2000;
rcv1_origin=IQ_final_samples*200;

%rotation=-pi/4;


r=sqrt((real(rcv1_origin)).^2+(imag(rcv1_origin)).^2);
length(rcv1_origin);
theta=zeros(length(rcv1_origin),1);
%scatterplot(rcv1_origin)
for i=1:length(rcv1_origin)
    if ((imag(rcv1_origin(i))>=0) && (real(rcv1_origin(i))>=0)) || ((imag(rcv1_origin(i))<0)&& (real(rcv1_origin(i))>=0))
        theta(i)=atan(imag(rcv1_origin(i))./real(rcv1_origin(i)));%is pi not dgeree
    elseif ((imag(rcv1_origin(i))<0) && (real(rcv1_origin(i))<0)) ||((imag(rcv1_origin(i))>=0) && (real(rcv1_origin(i))<0))
        theta(i)=atan(imag(rcv1_origin(i))./real(rcv1_origin(i)))+pi;%is pi not dgeree
    end
end



% Different rotation
for i=1:length(rcv1_origin)

x_new(i)=r(i).*cos(theta(i)-0);
y_new(i)=r(i).*sin(theta(i)-0);
rcv1_0(i)=x_new(i)+y_new(i)*j;
%scatterplot(rcv1)
end

for i=1:length(rcv1_origin)

x_new(i)=r(i).*cos(theta(i)-pi/4);
y_new(i)=r(i).*sin(theta(i)-pi/4);
rcv1_pi4m(i)=x_new(i)+y_new(i)*j;
%scatterplot(rcv1)
end

for i=1:length(rcv1_origin)

x_new(i)=r(i).*cos(theta(i)+pi/4);
y_new(i)=r(i).*sin(theta(i)+pi/4);
rcv1_pi4p(i)=x_new(i)+y_new(i)*j;
%scatterplot(rcv1)
end

for i=1:length(rcv1_origin)

x_new(i)=r(i).*cos(theta(i)+pi/2);
y_new(i)=r(i).*sin(theta(i)+pi/2);
rcv1_pi2p(i)=x_new(i)+y_new(i)*j;
%scatterplot(rcv1)
end




%scatterplot(rcv1);



%set the weights arry

Four_result_max=0;
for i=1:import_signal_no


for ri=1:4



if (ri==1)
    rcv_tmp=rcv1_0+XY_scale+XY_scale*1i;
    weights_test=zeros(100);
elseif (ri==2)
    rcv_tmp=rcv1_pi4m+XY_scale+XY_scale*1i;
    weights_test=zeros(100);
elseif (ri==3)
    rcv_tmp=rcv1_pi4p+XY_scale+XY_scale*1i;
    weights_test=zeros(100);
elseif (ri==4)
    rcv_tmp=rcv1_pi2p+XY_scale+XY_scale*1i;
    weights_test=zeros(100);
end









for b=1:sample_no1  %1000 is no. of sample
    x_point=round(real(rcv_tmp(b))/grid_scale);
    y_point=round(imag(rcv_tmp(b))/grid_scale);
    if (x_point>0)&&(y_point>0)&&(x_point<2*XY_scale/grid_scale)&&(y_point<2*XY_scale/grid_scale)
        %if there is an point in the grid, then weight of this grade will +1
        weights_test(x_point,y_point)=weights_test(x_point,y_point)+1;
        
    end
end





results_2PSK=weights_test.*weights_2PSK;
sum_2PSK=sum(results_2PSK,'all');


results_4PSK=weights_test.*weights_4PSK;
sum_4PSK=sum(results_4PSK,'all');


results_8PSK=weights_test.*weights_8PSK;
sum_8PSK=sum(results_8PSK,'all');


% results_16PSK=weights_test.*weights_16PSK;
% sum(results_16PSK,'all')


results_16QAM=weights_test.*weights_16QAM;
sum_16QAM=sum(results_16QAM,'all');

sum_matrix=[sum_16QAM,sum_8PSK,sum_4PSK,sum_2PSK];

results_max=max(sum_matrix);


if (results_max>Four_result_max)
    Four_result_max=results_max;

    sample_count_2PSK_temp=0;
    sample_count_4PSK_temp=0;
    sample_count_8PSK_temp=0;
    sample_count_16QAM_temp=0;
    if (results_max==sum_2PSK)
        sample_count_2PSK_temp=sample_count_2PSK_temp+1;
    elseif (results_max==sum_4PSK)
        sample_count_4PSK_temp=sample_count_4PSK_temp+1;
    elseif (results_max==sum_8PSK)
        sample_count_8PSK_temp=sample_count_8PSK_temp+1;
    elseif (results_max==sum_16QAM)
        sample_count_16QAM_temp=sample_count_16QAM_temp+1;
    end

end






end % end of rotation


    if (sample_count_2PSK_temp==1)
        sample_count_2PSK=sample_count_2PSK+1;
    elseif (sample_count_4PSK_temp==1)
        sample_count_4PSK=sample_count_4PSK+1;
    elseif (sample_count_8PSK_temp==1)
        sample_count_8PSK=sample_count_8PSK+1;
    elseif (sample_count_16QAM_temp==1)
        sample_count_16QAM=sample_count_16QAM+1;
    end









end
sample_count_2PSK
sample_count_4PSK
sample_count_8PSK
sample_count_16QAM

sample_count_2PSK=0;
sample_count_4PSK=0;
sample_count_8PSK=0;
sample_count_16QAM=0;















