package com.yjkj.chainup.util;

import android.text.TextUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.model.FileHeader;
import net.lingala.zip4j.model.ZipParameters;
import net.lingala.zip4j.model.enums.CompressionLevel;
import net.lingala.zip4j.model.enums.CompressionMethod;
import net.lingala.zip4j.model.enums.EncryptionMethod;

/**
 *ZIP compressed file operation tool class
 *Password support
 *Relying on zip4j open source projects（ http://www.lingala.net/zip4j/ ）
 *Version 1.3.1
 * @author ninemax
 */
public class CompressUtil {

    /**
     *Extract the specified ZIP compressed file using the given password to the specified directory
     * <p>
     *If the specified directory does not exist, it can be automatically created, and illegal paths will cause exceptions to be thrown
     *@param zip specified ZIP compressed file
     *@param dest Decompress directory
     *Password for @param passwd ZIP file
     *@return Decompressed file array
     *@ throws ZipException: The compressed file is damaged or the decompression failed
     */
    public static File [] unzip(String zip, String dest, String passwd) throws ZipException {
        File zipFile = new File(zip);
        return unzip(zipFile, dest, passwd);
    }

    /**
     *Extract the specified ZIP compressed file to the current directory using the given password
     *@param zip specified ZIP compressed file
     *Password for @param passwd ZIP file
     *@return Decompressed file array
     *@ throws ZipException: The compressed file is damaged or the decompression failed
     */
    public static File [] unzip(String zip, String passwd) throws ZipException {
        File zipFile = new File(zip);
        File parentDir = zipFile.getParentFile();
        return unzip(zipFile, parentDir.getAbsolutePath(), passwd);
    }

    /**
     *Extract the specified ZIP compressed file using the given password to the specified directory
     * <p>
     *If the specified directory does not exist, it can be automatically created, and illegal paths will cause exceptions to be thrown
     *@param zip specified ZIP compressed file
     *@param dest Decompress directory
     *Password for @param passwd ZIP file
     *@return Decompressed file array
     *@ throws ZipException: The compressed file is damaged or the decompression failed
     */
    public static File [] unzip(File zipFile, String dest, String passwd) throws ZipException {
        ZipFile zFile = new ZipFile(zipFile);
        if (!zFile.isValidZipFile()) {
            throw new ZipException("压缩文件不合法,可能被损坏.");
        }
        File destDir = new File(dest);
        if (destDir.isDirectory() && !destDir.exists()) {
            destDir.mkdir();
        }
        if (zFile.isEncrypted()) {
            zFile.setPassword(passwd.toCharArray());
        }
        zFile.extractAll(dest);

        List<FileHeader> headerList = zFile.getFileHeaders();
        List<File> extractedFileList = new ArrayList<File>();
        for(FileHeader fileHeader : headerList) {
            if (!fileHeader.isDirectory()) {
                extractedFileList.add(new File(destDir,fileHeader.getFileName()));
            }
        }
        File [] extractedFiles = new File[extractedFileList.size()];
        extractedFileList.toArray(extractedFiles);
        return extractedFiles;
    }

    /**
     *Compress the specified file to the current folder
     *@param src The specified file to compress
     *@return The absolute path where the final compressed file is stored. If it is null, it indicates compression failure
     */
    public static String zip(String src) {
        return zip(src,null);
    }

    /**
     *Compress the specified file or folder to the current directory using the given password
     *@param src file to compress
     *Password used for @param passwd compression
     *@return The absolute path where the final compressed file is stored. If it is null, it indicates compression failure
     */
    public static String zip(String src, String passwd) {
        return zip(src, null, passwd);
    }

    /**
     *Compress the specified file or folder to the current directory using the given password
     *@param src file to compress
     *@param dest compressed file storage path
     *Password used for @param passwd compression
     *@return The absolute path where the final compressed file is stored. If it is null, it indicates compression failure
     */
    public static String zip(String src, String dest, String passwd) {
        return zip(src, dest, true, passwd);
    }

    /**
     *Compress the specified file or folder to the specified location using the given password
     * <p>
     *Dest can transfer the absolute path where the final compressed file is stored, as well as the directory, null, or ''< Br/>
     *If null or '' is passed, the compressed file will be stored in the current directory, which is the same directory as the source file. The compressed file name will take the source file name with a. zip suffix< Br/>
     *If it ends with a path separator (File. separator), it is considered a directory, and the compressed file name takes the source file name with a. zip suffix. Otherwise, it is considered a file name
     *@param src file or folder path to compress
     *@param dest compressed file storage path
     *Does @param isCreateDir create a directory in a compressed file? Only valid if the compressed file is a directory< Br/>
     *If false, the files in the directory will be directly compressed to the compressed file
     *Password used for @param passwd compression
     *@return The absolute path where the final compressed file is stored. If it is null, it indicates compression failure
     */
    public static String zip(String src, String dest, boolean isCreateDir, String passwd) {
        File srcFile = new File(src);
        dest = buildDestinationZipFilePath(srcFile, dest);
        ZipParameters parameters = new ZipParameters();
        parameters.setCompressionMethod(CompressionMethod.DEFLATE);           //Compression method
        parameters.setCompressionLevel(CompressionLevel.NORMAL);    //Compression level
        if (!TextUtils.isEmpty(passwd)) {
            parameters.setEncryptFiles(true);
            parameters.setEncryptionMethod(EncryptionMethod.ZIP_STANDARD); //Encryption method
        }
        try {
            ZipFile zipFile = new ZipFile(dest);
            if (srcFile.isDirectory()) {
                //If no directory is created, the files under the given directory will be compressed directly into a compressed file, meaning there is no directory structure
                if (!isCreateDir) {
                    File [] subFiles = srcFile.listFiles();
                    ArrayList<File> temp = new ArrayList<File>();
                    Collections.addAll(temp, subFiles);
                    zipFile.addFiles(temp, parameters);
                    return dest;
                }
                zipFile.addFolder(srcFile, parameters);
            } else {
                zipFile.addFile(srcFile, parameters);
            }
            return dest;
        } catch (ZipException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     *Build a compressed file storage path. If it does not exist, it will be created
     *The input may be a file name or directory, or it may not be passed in. This method is used to convert the storage path of the final compressed file
     *@param srcFile Source File
     *@param destParam compresses the target path
     *@return The correct path for storing compressed files
     */
    private static String buildDestinationZipFilePath(File srcFile,String destParam) {
        if (TextUtils.isEmpty(destParam)) {
            if (srcFile.isDirectory()) {
                destParam = srcFile.getParent() + File.separator + srcFile.getName() + ".zip";
            } else {
                String fileName = srcFile.getName().substring(0, srcFile.getName().lastIndexOf("."));
                destParam = srcFile.getParent() + File.separator + fileName + ".zip";
            }
        } else {
            createDestDirectoryIfNecessary(destParam);  //Create the specified path if it does not exist
            if (destParam.endsWith(File.separator)) {
                String fileName = "";
                if (srcFile.isDirectory()) {
                    fileName = srcFile.getName();
                } else {
                    fileName = srcFile.getName().substring(0, srcFile.getName().lastIndexOf("."));
                }
                destParam += fileName + ".zip";
            }
        }
        return destParam;
    }

    /**
     *Create a compressed file storage directory if necessary, such as if the specified storage path has not been created
     *The storage path specified by @param destParam may not have been created
     */
    private static void createDestDirectoryIfNecessary(String destParam) {
        File destDir = null;
        if (destParam.endsWith(File.separator)) {
            destDir = new File(destParam);
        } else {
            destDir = new File(destParam.substring(0, destParam.lastIndexOf(File.separator)));
        }
        if (!destDir.exists()) {
            destDir.mkdirs();
        }
    }
}
