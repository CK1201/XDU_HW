clc,clear
close all
SNRSet = 0.01:0.01:18;
PfaSet = [10^-2, 10^-4, 10^-6, 10^-8];
result = zeros(length(SNRSet),length(PfaSet));
figure()
hold on
grid on
box off
for j = 1:length(PfaSet)
    for i = 1:length(SNRSet)
        result(i,j)=marcumsq(sqrt(2*SNRSet(i)),sqrt(-2*log(PfaSet(j))));
    end
    plot(SNRSet,result(:,j),'LineWidth',2);
end
legend('10^{-2}','10^{-4}','10^{-6}','10^{-8}','location','best')
xlabel('单个脉冲SNR/dB')
ylabel('检测概率')