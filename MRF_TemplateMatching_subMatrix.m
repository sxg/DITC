 function [t1im, t2im, dfim, m0im,ipim,indexm,fitting_im] = MRF_TemplateMatching_subMatrix(recon_images, dict,r,dfrange,index, Nperpart);

% MR Fingerpriting,  Template Matching code
% 
% this version has lower memory requirement 
% Nperpart divides the number of index into smaller bins   
% 
% input : recon_images :  reconstructed images, size=(Nimages, siz, siz, Npartitions) 
%         dict : dictionary, size=(Nimage, r, dfrange) 
%         r :  T1 and T2 combinations, 1st column = T1, 2nd column = T2, unit in ms 
%         dfrange : off-resonance range, unit in Hz         
%         index : index of the mask that covers the ROI. in order to reduce the computation 
%         Nperpart : divides the number of index into smaller bins. number of pixels in each bin.
% 
% output : T1, T2, off-resonance(df), proton density (m0) maps; 
%          ipim : map of the maximum inner-product values
%          indexm : index of the columns that have Maximum
%          inner product values 
%          fitting_im: fitting results size=(Nimage, siz, siz) 
%
%
% Dan Ma, Case Western Reserve University  dxm302@case.edu  9/9/2013 


%     Nperpart = 4000;
    
    xycomp2D = single(squeeze(dict(:,:,:)));
    xycomp2D = xycomp2D(:,:);
    xycomp2D_norm = sqrt(sum(xycomp2D.*conj(xycomp2D)));
    clear dict
    
    [Nimage siz siz Npart] = size(recon_images);
    
    t1im = zeros(Npart,siz,siz,'single');
    t2im = zeros(Npart,siz,siz,'single');
    dfim = zeros(Npart,siz,siz,'single');
    m0im = zeros(Npart,siz,siz,'single');
    ipim = zeros(Npart,siz,siz,'single');
    fitting_im = zeros(Npart,Nimage,siz,siz,'single');
    
    ipart = 1;
        im = squeeze(recon_images(:,:,:,ipart));
        clear recon_images;
        pstart = 1;
        pend = Nimage;
        
        index0 = index;
        Nind = floor(length(index0)/Nperpart);
        indexm = [];
        value = [];
        
        for iind = 1:Nind
            index = index0(((iind-1)*Nperpart+1):(iind*Nperpart));
            xx = (squeeze(im(pstart:pend,index))).';
            xx_norm = sqrt(sum(xx.*conj(xx),2));

            norm_all = xx_norm*xycomp2D_norm;
            clear xx_norm;

            inner_product = conj(xx)*xycomp2D./norm_all;
            clear norm_all;
    
            [value1 indexm1] = max(abs(inner_product),[],2);
            clear inner_product
            
            indexm = [indexm;indexm1];
            value = [value;value1];
            iind
        end
        
            index = index0(((iind)*Nperpart+1):end);
            xx = (squeeze(im(pstart:pend,index))).';
            xx_norm = sqrt(sum(xx.*conj(xx),2));

            norm_all = xx_norm*xycomp2D_norm;
            clear xx_norm;

            inner_product = conj(xx)*xycomp2D./norm_all;
            clear norm_all;
    
            [value1 indexm1] = max(abs(inner_product),[],2);
            clear inner_product
            
            indexm = [indexm;indexm1];
            value = [value;value1];
        
        index = index0;
        Nindex = length(index);    
        xx = (squeeze(im(pstart:pend,index))).';
        recon_save = zeros(length(pstart:pend),Nindex,'single');
        coef_save = zeros(1,Nindex,'single');
        ip_iter = (value);
        dict_col = xycomp2D(:,indexm);

        for iindex = 1:Nindex
            coef_save(iindex) = pinv(dict_col(:,iindex))*xx(iindex,:).';
            recon_save(:,iindex) = dict_col(:,iindex)*coef_save(iindex);
        end

        [t1t2r dfc] = ind2sub([size(r,1), length(dfrange)],indexm);
        t1_save= r(t1t2r(:),1);
        t2_save = r(t1t2r(:),2);
        offreson_save = dfrange(dfc(:));
        
        t1im(ipart,index) = t1_save;
        t2im(ipart,index) = t2_save;
        dfim(ipart,index) = offreson_save;
        m0im(ipart,index) = abs(coef_save);
        ipim(ipart,index) = ip_iter;
        fitting_im(ipart,:,index) = squeeze(recon_save);
        
%         ipart        
        t1im = squeeze(t1im);
        t2im = squeeze(t2im);
        dfim = squeeze(dfim);
        m0im = squeeze(m0im);
        ipim = squeeze(ipim);
        fitting_im = squeeze(fitting_im);
%     
 end
    