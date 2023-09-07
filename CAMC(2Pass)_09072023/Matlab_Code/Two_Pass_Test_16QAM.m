% V1.0.5   !! PSK Modulation Change in line 66(M), line 87-95 is for 16QAM
% update in V1.0.5 : add import signal no. to test correct rate line 55
%                    calculate guess output in line 187-212 fix out of 
%                    region bug in line 161-165, input noiseinclude

% update in V1.0.4 : eliminate input signal sample multiplication in line
%                    52, which means no pre-processing needed


% update in V1.0.3 : use same no. of point to avoid scatering
%                    no. of BPSK, QPSK, 8PSK, and 16QAM will be
%                    1:2:4:8 to make sure each constellation point has 
%                    same amount of signal points

% update in V1.0.2 : add test signal for 2PSK, 4PSK, 8PSK, 16PSK, 16QAM
% update in V1.0.1 : add test function of 2PSK, 4PSK, 8PSK, 16PSK, 16QAM


clc;
int8 tmp_comp_R;
int8 tmp_comp_I;
int8 tmp_large_R;
int8 tmp_large_I;
%this 4 integers are for scales of constellation

int8 XY_scale;
%declare larger one between X and Y to decide the scale of constellation

double grid_scale;
%declare grid scare to measure the weights square

int8 XY_length;
%declare the length of X&Y, XY_length = XY_scale / grid_scale

int8 sample_no;
%declare the number of samples


%Input from device or Matlab for testing


sample_no1=6000;
sample_count_2PSK=0;
sample_count_4PSK=0;
sample_count_8PSK=0;
sample_count_16QAM=0;


import_signal_no=100;

%for noise_input=0:20

noise_input=20;


% import/generate signals



Four_result_max=0;
for ii=1:import_signal_no

% BPSK QPSK 8PSK

% Generate random data symbols, and then apply QPSK modulation.
% 
%     M=4;
%     refC1 = randi([0 M-1],sample_no1,1);
% 
% 
%     if (M==2)||(M==8)
%         phase_t=0;
%     else
%         phase_t=pi/M;
%     end
% 
%     tx_t = pskmod(refC1,M,phase_t);
%     rcv1_origin = awgn(tx_t,noise_input);


% 16QAM

M = 16;
refC1 = qammod(0:M-1,M);
constDiagram = comm.ConstellationDiagram('ReferenceConstellation',refC1, ...
    'XLimits',[-4 4],'YLimits',[-4 4]);
data1 = randi([0 M-1],sample_no1,1);
sym1 = qammod(data1,M);
rcv1_origin = awgn(sym1,0);

%constDiagram(rcv1)





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




for ri=1:4



if (ri==1)
    rcv_tmp=rcv1_0+XY_scale+XY_scale*1i;
    weights_test=zeros(XY_scale/grid_scale*2);
elseif (ri==2)
    rcv_tmp=rcv1_pi4m+XY_scale+XY_scale*1i;
    weights_test=zeros(XY_scale/grid_scale*2);
elseif (ri==3)
    rcv_tmp=rcv1_pi4p+XY_scale+XY_scale*1i;
    weights_test=zeros(XY_scale/grid_scale*2);
elseif (ri==4)
    rcv_tmp=rcv1_pi2p+XY_scale+XY_scale*1i;
    weights_test=zeros(XY_scale/grid_scale*2);
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
sum_2PSK=0;

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

















