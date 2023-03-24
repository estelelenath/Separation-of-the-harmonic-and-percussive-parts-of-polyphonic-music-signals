clear, clc, close all
%% Ohne Residual, Ohne Iterativ,
%  Harmonische Spektrum = N_4096, Perkussiven Spektrum = N_256
%  gefilterte Har=Harmonische Spektrum*harmony filter
%  gefilterte Per=Perkussive Spektrum*perkussiv filter
%% music Signal (Original)
[x, fs] = audioread('F:\Bachelorarbeit\Music\harpertest2.mp3'); %orginal Music    
x = x(:, 1);

figure(11)
N = length(x);
t_1 = linspace(0, N/fs, N);
plot(t_1, x);
title('orginale Musik')
xlabel('Zeit')
ylabel('Amplitude')

%% signal parameters

xlen = length(x);
t = (0:xlen-1)/fs;  

%harmonisch
N_har=8192;
wlen_har = N_har;      %size of 4096points (HammingWindow)
hop_har = wlen_har/4;  %number of points for repeating the window (noverlap)
nfft_har = wlen_har;   % size of the fft
%perkussiv
N_per=256;        
wlen_per = N_per;      %size of 256points (HammingWindow)
hop_per = wlen_per/4;  %number of points for repeating the window (noverlap)
nfft_per = wlen_per;   %size of the fft

har_schwellenwert=0.5;
per_schwellenwert=0.5;

beta_erste = 2; %je höhere Separation Faktor deutlicher Filter aber schwingt
beta_zweite = 3.5; %1.2
%% erste
%Spektrogram des originalen Signals(har)
figure(12)
[stft_erste, f, t_stft] = stft(x, wlen_har, hop_har, nfft_har, fs);
%spectrogram(x,wlen_har,hop_har,nfft_har,fs,'yaxis')
imagesc(t,f,abs(stft_erste));
set(gca,'YDir','normal');
title('Spectrogram STFT(erste_har)')
xlabel('Zeit')
ylabel('Frequenz')

%Separation (Harmonische | Perkussive) mit dem Median Filter
figure(13)
angle_stft_erste_har=angle(stft_erste);
sep_stft_erste_har=medfilt2(abs(stft_erste), [1 22]); %Median filter 200ms
imagesc(t,f,sep_stft_erste_har);
set(gca,'YDir','normal');
title('Spectrogram erste_har')
xlabel('Zeit')
ylabel('Frequenz')

%Separation (Perkussive | Harmonische) mit dem Median Filter [nur für Maskingrechnung]
figure(14)
angle_stft_erste_per=angle(stft_erste);
sep_stft_erste_per=medfilt2(abs(stft_erste), [47 1]); %median filter 500Hz
imagesc(t,f,sep_stft_erste_per);
set(gca,'YDir','normal');
title('Spectrogram erste_per')
xlabel('Zeit')
ylabel('Frequenz')

%binary Masking (harmonische Teil)
figure(15)
epsilon_erste = realmin;
mask_sep_stft_erste_har=((sep_stft_erste_har./(sep_stft_erste_per+epsilon_erste))>beta_erste); %hard
%mask_sep_stft_erste_har=(sep_stft_erste_har./(sep_stft_erste_har+sep_stft_erste_per+epsilon_erste)); %soft
imagesc(t,f,mask_sep_stft_erste_har);
set(gca,'YDir','normal');
title('binary_mask_erste_harmony_beta')
xlabel('Zeit')
ylabel('Frequenz')




%zweite Masking (binary mask nach Schwellenwert)
%figure(15)
%mask_sep_stft_erste_har=(sep_stft_erste_har>har_schwellenwert);
%imagesc(t,f,mask_sep_stft_erste_har);
%set(gca,'YDir','normal');
%title('binary_mask_harmische_Schwellenwert')
%xlabel('time')
%ylabel('frequency')


%Orginal Musiksignal*binary Mask_harm=harmonisch gemaskte Orginal Musik
figure(16)
masked_original_har=stft_erste.*mask_sep_stft_erste_har;
imagesc(t,f,abs(masked_original_har));
set(gca,'YDir','normal');
title('masked_original_harm')
xlabel('Zeit')
ylabel('Frequenz')

%Restteil=orginal-harmonisch gemaskte Orginal Musik (=Residual+Perkussiv)
figure(17)
stft_erste_rest=stft_erste-masked_original_har;
imagesc(t,f,abs(stft_erste_rest));
set(gca,'YDir','normal');
title('masked_restteil')
xlabel('Zeit')
ylabel('Frequenz')

%erste Wiederhellstellung von Spektrogram(stft) zum Musiksignal(=istft)
figure(18)
[istft_masked_har, t_istft] = istft(masked_original_har, wlen_har, hop_har, nfft_har, fs);
%transf_x_istft_har=x_istft_har.';
N = length(istft_masked_har);
t_1 = linspace(0, N/fs, N);
plot(t_1, istft_masked_har);
title('istft_masked_har')
xlabel('Zeit')
ylabel('Amplitude')

figure(19)
[istft_masked_rest, t_istft] = istft(stft_erste_rest, wlen_har, hop_har, nfft_har, fs);
%transf_x_istft_har=x_istft_har.';
N = length(istft_masked_rest);
t_1 = linspace(0, N/fs, N);
plot(t_1, istft_masked_rest);
title('istft_masked_rest')
xlabel('Zeit')
ylabel('Amplitude')

%% zweite
%Spektrogram für perkussiven Teil(small frame)
figure(20)
[stft_zweite, f, t_stft] = stft(x, wlen_per, hop_per, nfft_per, fs);
%spectrogram(x,wlen_per,hop_per,nfft_per,fs,'yaxis')
imagesc(t,f,abs(stft_zweite));
set(gca,'YDir','normal');
title('Spectrogram zweite STFT(residual+perkussiv)')
xlabel('Zeit')
ylabel('Frequenz')

%Separation (Perkussive | Harmonische) mit dem Median Filter
figure(21)
angle_stft_zweite_per=angle(stft_zweite);
sep_stft_zweite_res_per=medfilt2(abs(stft_zweite), [5 1]);
imagesc(t,f,abs(sep_stft_zweite_res_per));
set(gca,'YDir','normal');
title('Spectrogram zweite STFT perkussiv')
xlabel('Zeit')
ylabel('Frequenz')

%Separation (Harmonische | Perkussive) mit dem Median Filter [nur für Maskingrechnung]
figure(22)
angle_stft_zweite_har=angle(stft_zweite);
sep_stft_zweite_har=medfilt2(abs(stft_zweite), [1 137]);
imagesc(t,f,abs(sep_stft_zweite_har));
set(gca,'YDir','normal');
title('Separation(harmonischen um binary Masking) mit dem Median filter')
xlabel('Zeit')
ylabel('Frequenz')

%zweite Masking (binary mask nach Schwellenwert)
%figure(23)
%masked_sep_stft_zweite_per=(sep_stft_zweite_res_per>per_schwellenwert);
%imagesc(t,f,masked_sep_stft_zweite_per);
%set(gca,'YDir','normal');
%title('binary_mask_perkussive_schwellenwert')
%xlabel('time')
%ylabel('frequency')


%binary Masking (perkussivische Teil)
figure(23)
epsilon_zweite = realmin;
masked_sep_stft_zweite_per=((sep_stft_zweite_res_per./(sep_stft_zweite_har+epsilon_zweite))>beta_zweite); %hard
%masked_sep_stft_zweite_per=(sep_stft_zweite_res_per./(sep_stft_zweite_res_per+sep_stft_zweite_har+epsilon_zweite)); %soft
imagesc(t,f,masked_sep_stft_zweite_per);
set(gca,'YDir','normal');
title('zweite_binary_mask_perkussiv')
xlabel('Zeit')
ylabel('Frequenz')

%Orginal Musiksignal*binary Mask_perk=perkussivisch gemaskte Orginal Musik
figure(24)
masked_original_per=stft_zweite.*masked_sep_stft_zweite_per;
imagesc(t,f,abs(masked_original_per));
set(gca,'YDir','normal');
title('masked_beta_original_res_per')
xlabel('Zeit')
ylabel('Frequenz')

%Residual=perkussivische und residuale orginal-perkussivisch gemaskte Orginal Musik (=Residual)
figure(25)
stft_res=stft_zweite-masked_original_per;
imagesc(t,f,abs(stft_res));
set(gca,'YDir','normal');
title('masked_beta_restteil')
xlabel('Zeit')
ylabel('Frequenz')

%erste Wiederhellstellung von Spektrogram(stft) zum Musiksignal(=istft)
figure(26)
[istft_masked_per, t_istft] = istft(masked_original_per, wlen_per, hop_per, nfft_per, fs);
%transf_x_istft_har=x_istft_har.';
N = length(istft_masked_per);
t_1 = linspace(0, N/fs, N);
plot(t_1, istft_masked_per);
title('istft_masked_beta_per')
xlabel('Zeit')
ylabel('Amplitude')

figure(27)
[istft_res, t_istft] = istft(stft_res, wlen_per, hop_per, nfft_per, fs);
%transf_x_istft_har=x_istft_har.';
N = length(istft_res);
t_1 = linspace(0, N/fs, N);
plot(t_1, istft_res);
title('istft_residual')
xlabel('Zeit')
ylabel('Amplitude')

%% Export
filename='outputtest_har.wav';
audiowrite(filename,istft_masked_har,fs);

filename='outputtest_per_res.wav';
audiowrite(filename,istft_masked_rest,fs);

filename='outputtest_per.wav';
audiowrite(filename,istft_masked_per,fs);

filename='outputtest_res.wav';
audiowrite(filename,istft_res,fs);
