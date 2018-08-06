clear all
close all
clc
rng('default')
alpha=0.05;
mode='10x10t';
alternative='less';
if     ismember(mode,{'5x2t' '5x2F'})
    R = 5;
    K = 2;
else
    R = 10;
    K = 10;
end

load Loss_FS_RF

load Loss_SVM

%% AlternaTE  C1 is in case of alternative to C2

C1=Loss_FS_RF;
C2=Loss_SVM;

loss1=C1;
loss2=C2;
delta = loss1 - loss2;

% If all loss values are equal, the classifiers are equivalent.
if all( abs(delta(:)) < 100*eps(loss1(:)+loss2(:)) )
    p = 1;
    h = false;
    return;
end

%
% Apply the chosen test.
%

switch mode
    case '5x2t'        
        mdelta_r = mean(delta,2);
        s2_r = sum(bsxfun(@minus,delta,mdelta_r).^2,2);
        s2 = sum(s2_r);
        t = delta(1,1)/sqrt(s2/5);
        
        switch alternative
            case 'unequal'
                p = 2*tcdf(-abs(t),5);
            case 'less'
                % delta has a large positive value under H1
                p = tcdf(t,5,'upper');
            case 'greater'
                % delta has a large negative value under H1
                p = tcdf(t,5);
        end
    
    case '5x2F'        
        mdelta_r = mean(delta,2);
        s2_r = sum(bsxfun(@minus,delta,mdelta_r).^2,2);
        s2 = sum(s2_r);
        F = sum(delta(:).^2)/(2*s2);
        
        p = fcdf(F,10,5,'upper'); % computed only for 'unequal' H1
    
    case '10x10t'        
        m = mean(delta(:));
        s2 = var(delta(:));
        t = m/sqrt(s2/(K+1));
        
        p = tcdf(t,K);

        switch alternative
            case 'unequal'
                p = 2*tcdf(-abs(t),K);
            case 'less'
                % delta has a large positive value under H1
                p = tcdf(t,K,'upper');
            case 'greater'
                % delta has a large negative value under H1
                p = tcdf(t,K);
        end
end

h = p<alpha;
