%started 21st May 2011- to create onsets
function [task]=make_ons_CATEG_ed1(onsCAT,task,param)
curr_sub=param.curr_sub;
n_dummies=6;
n_vol=param.nscan-n_dummies; %i.2. 399-6=393 volumes for MOST SUBJECTS
n_vol=n_vol(1); %i.e. take number of volumes in first session

TR=2.88; %secs
nsess=1;
ntask=2;

indx_trials={};
indx_trials{1}=task(1).sess(1).all_tri; %SELF Trials
indx_trials{2}=task(2).sess(1).all_tri; %SELF Trials
for k=1:nsess %sess
    for j=1:ntask
        
        %determine increment
        switch k
            case 1
                incr=0;
            case 2
                incr=(n_vol*TR);
                
        end
        if curr_sub==1 || curr_sub==2 %onsCAT created and added to their mat file by hand (i.e. onsets same for all subjects)
        tmp_ons=1000*onsCAT.stimonset(indx_trials{j});
        tmp_ons=tmp_ons+incr-onsCAT.starttime; %add increment and take away starttime    
        else
        tmp_ons=1000*onsCAT{k}.stimonset(indx_trials{j});
        tmp_ons=tmp_ons+incr-onsCAT{k}.starttime; %add increment and take away starttime
        end
        task(j).sess(k).onsets=tmp_ons;
    end
end

%no need to concatenate in Self CAT
% for i=1:ntask
%     
%     task(i).all_sess.onsets=[];
%     
%     for k=1:nsess
%         
%         
%         task(i).all_sess.onsets=[task(i).all_sess.onsets task(i).sess(k).onsets];
%         
%         
%     end
% end
