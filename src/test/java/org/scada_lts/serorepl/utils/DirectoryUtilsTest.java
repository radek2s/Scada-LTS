package org.scada_lts.serorepl.utils;

import org.junit.Test;

import java.io.File;

import static org.junit.Assert.*;

public class DirectoryUtilsTest {
    @Test
    public void getDirectorySize() throws Exception {

        Assert.assertEquals(DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api/vo")).getSize() , com.serotonin.util.DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api/vo")).getSize());
        Assert.assertEquals(DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api/da")).getSize() , com.serotonin.util.DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api/da")).getSize());
        Assert.assertEquals(DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api/config")).getSize() , com.serotonin.util.DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api/config")).getSize());
        Assert.assertEquals(DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api")).getSize() , com.serotonin.util.DirectoryUtils.getDirectorySize(new File("src/br/org/scadabr/api")).getSize());


    }
}