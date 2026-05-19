package com.yjkj.chainup.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class ZipUtils {
    public static void zip(String src, String dest) {
        //Define compressed output stream
        ZipOutputStream out = null;
        try {
            //Incoming Source File
            File outFile = new File(dest);
            File fileOrDirectory = new File(src);
            //Incoming compressed output stream
            out = new ZipOutputStream(new FileOutputStream(outFile));
            //Determine if it is a file or directory
            //If it is a file, compress it
            if (fileOrDirectory.isFile()) {
                zipFileOrDirectory(out, fileOrDirectory, "");
            } else {
                //Otherwise, list all files in the directory and recursively compress them
                File[] entries = fileOrDirectory.listFiles();
                for (int i = 0; i < entries.length; i++) {
                    zipFileOrDirectory(out, entries[i], "");
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            if (out != null) {
                try {
                    out.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    private static void zipFileOrDirectory(ZipOutputStream out, File fileOrDirectory, String curPath) {
        FileInputStream in = null;
        try {
            //Determine if the directory is null
            if (!fileOrDirectory.isDirectory()) {
                byte[] buffer = new byte[4096];
                int bytes_read;
                in = new FileInputStream(fileOrDirectory);
                //Archive compressed directory
                ZipEntry entry = new ZipEntry(curPath + fileOrDirectory.getName());
                //Write compressed directory to output stream
                out.putNextEntry(entry);
                while ((bytes_read = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytes_read);
                }
                out.closeEntry();
            } else {
                //List all files in the directory
                File[] entries = fileOrDirectory.listFiles();
                for (int i = 0; i < entries.length; i++) {
                    //Recursive compression
                    zipFileOrDirectory(out, entries[i], curPath + fileOrDirectory.getName() + "/");
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }
}
