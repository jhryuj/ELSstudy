function [result, msg] = unzip_niigz(sourcefolder,sourcefile,destfolder)
    result = 1;    
    
    try
        gunzip(fullfile(sourcefolder,sourcefile),destfolder)
        msg = [sourcefile ' extracted with gunzip'];
    catch error
        try 
            nii = readFileNifti(fullfile(sourcefolder,sourcefile)); 
            nii.fname = fullfile(fullfile(destfolder,sourcefile(1:end-3))); 
            writeFileNifti(nii)
            msg = [sourcefile 'extracted with mrVista'];
        catch error               
%             try 
%                 [status,result] = system(['ml system']);
%                 [status,result] = system(['ml p7zip']);
%                 %[status,result] = system(['"C:\Program Files\7za920\7za.exe" -y x ' '"' filename{f} '"' ' -o' '"' outputDir '"']);
%                 msg = 'extracted with 7z';
%             catch error
        result = 0;
        msg = '';
%             end
        end
    end
    
    disp(msg);
end