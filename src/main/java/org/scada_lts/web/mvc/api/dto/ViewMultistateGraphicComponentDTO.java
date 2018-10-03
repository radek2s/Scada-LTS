package org.scada_lts.web.mvc.api.dto;

import com.serotonin.db.IntValuePair;

import java.util.ArrayList;
import java.util.List;

/**
 * @Author Arkadiusz Parafiniuk
 * arkadiusz.parafiniuk@gmail.com
 */
public class ViewMultistateGraphicComponentDTO extends ViewImageSetComponentDTO {
    private List<IntValuePair> stateImageMap = new ArrayList<>();
    private int defaultImage;

    public ViewMultistateGraphicComponentDTO() {
    }

    public ViewMultistateGraphicComponentDTO(String id, int index, String defName, String idSuffix, String style, int x, int y, String dataPointXid, String nameOverride, boolean settableOverride, String bkgdColorOverride, boolean displayControls, String imageSet, boolean displayText, List<IntValuePair> stateImageMap, int defaultImage) {
        super(id, index, defName, idSuffix, style, x, y, dataPointXid, nameOverride, settableOverride, bkgdColorOverride, displayControls, imageSet, displayText);
        this.stateImageMap = stateImageMap;
        this.defaultImage = defaultImage;
    }

    public List<IntValuePair> getStateImageMap() {
        return stateImageMap;
    }

    public void setStateImageMap(List<IntValuePair> stateImageMap) {
        this.stateImageMap = stateImageMap;
    }

    public int getDefaultImage() {
        return defaultImage;
    }

    public void setDefaultImage(int defaultImage) {
        this.defaultImage = defaultImage;
    }
}
