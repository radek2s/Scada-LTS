package org.scada_lts.serorepl.utils;

import com.serotonin.util.ObjectUtils;
import org.junit.Test;

import static org.junit.Assert.*;

public class ObjectUtilTest {
    @Test
    public void isEqual() throws Exception {
        String nullString = null;
        String s1 = "TEST";
        int i = 21;

        Assert.assertEquals(ObjectUtil.isEqual(s1,s1)  , ObjectUtils.isEqual(s1,s1));
        Assert.assertEquals(ObjectUtil.isEqual(i, i)  , ObjectUtils.isEqual(i, i));
        Assert.assertEquals(ObjectUtil.isEqual(s1, nullString)  , ObjectUtils.isEqual(s1, nullString));
        Assert.assertEquals(ObjectUtil.isEqual(i, nullString)  , ObjectUtils.isEqual(i, nullString));
        Assert.assertEquals(ObjectUtil.isEqual(nullString, nullString)  , ObjectUtils.isEqual(nullString, nullString));
        Assert.assertEquals(ObjectUtil.isEqual(null,null)  , ObjectUtils.isEqual(null, null));
    }

}