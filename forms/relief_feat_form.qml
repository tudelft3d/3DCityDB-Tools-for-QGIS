<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology|Symbology3D|Fields|Forms" version="3.22.3-Białowieża">
  <renderer-3d type="vector" layer="citydb_relief_feat_lod1_ed5529a5_6945_4841_abb9_d81767b43253">
    <vector-layer-3d-tiling zoom-levels-count="3" show-bounding-boxes="0"/>
    <symbol type="polygon" material_type="phong">
      <data rendered-facade="3" alt-binding="centroid" height="0" add-back-faces="0" invert-normals="0" alt-clamping="relative" culling-mode="no-culling" extrusion-height="0"/>
      <material specular="255,255,255,255" diffuse="213,178,160,255" ambient="25,25,25,255" shininess="0">
        <data-defined-properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data-defined-properties>
      </material>
      <data-defined-properties>
        <Option type="Map">
          <Option name="name" type="QString" value=""/>
          <Option name="properties"/>
          <Option name="type" type="QString" value="collection"/>
        </Option>
      </data-defined-properties>
      <edges color="0,0,0,255" width="1" enabled="0"/>
    </symbol>
  </renderer-3d>
  <renderer-v2 forceraster="0" symbollevels="0" type="singleSymbol" enableorderby="0" referencescale="-1">
    <symbols>
      <symbol name="0" alpha="1" type="fill" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" enabled="1" class="SimpleFill" locked="0">
          <Option type="Map">
            <Option name="border_width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="color" type="QString" value="213,178,160,255"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="offset" type="QString" value="0,0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="outline_color" type="QString" value="0,0,0,255"/>
            <Option name="outline_style" type="QString" value="solid"/>
            <Option name="outline_width" type="QString" value="0.26"/>
            <Option name="outline_width_unit" type="QString" value="MM"/>
            <Option name="style" type="QString" value="solid"/>
          </Option>
          <prop k="border_width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="color" v="213,178,160,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
    <rotation/>
    <sizescale/>
  </renderer-v2>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <fieldConfiguration>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="termination_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_terrain" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="FilterExpression" type="QString" value="name = 'RelativeToTerrainType'"/>
            <Option name="Key" type="QString" value="value"/>
            <Option name="Layer" type="QString" value="v_enumeration_value_5be4fe02_ee51_4aee_83a9_2e6c3954d54e"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="FilterExpression" type="QString" value="name = 'RelativeToWaterType'"/>
            <Option name="Key" type="QString" value="value"/>
            <Option name="Layer" type="QString" value="v_enumeration_value_5be4fe02_ee51_4aee_83a9_2e6c3954d54e"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="lod" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="ID" field="id" index="0"/>
    <alias name="GML ID" field="gmlid" index="1"/>
    <alias name="GML codespace" field="gmlid_codespace" index="2"/>
    <alias name="Name" field="name" index="3"/>
    <alias name="Name codespace" field="name_codespace" index="4"/>
    <alias name="Description" field="description" index="5"/>
    <alias name="Creation Date" field="creation_date" index="6"/>
    <alias name="Termination Date" field="termination_date" index="7"/>
    <alias name="Relative to Terrain" field="relative_to_terrain" index="8"/>
    <alias name="Relative to Water" field="relative_to_water" index="9"/>
    <alias name="Latest Modification" field="last_modification_date" index="10"/>
    <alias name="Updating person" field="updating_person" index="11"/>
    <alias name="Updating Reason" field="reason_for_update" index="12"/>
    <alias name="Lineage" field="lineage" index="13"/>
    <alias name="" field="lod" index="14"/>
  </aliases>
  <defaults>
    <default field="id" expression="" applyOnUpdate="0"/>
    <default field="gmlid" expression="" applyOnUpdate="0"/>
    <default field="gmlid_codespace" expression="" applyOnUpdate="0"/>
    <default field="name" expression="" applyOnUpdate="0"/>
    <default field="name_codespace" expression="" applyOnUpdate="0"/>
    <default field="description" expression="" applyOnUpdate="0"/>
    <default field="creation_date" expression="" applyOnUpdate="0"/>
    <default field="termination_date" expression="" applyOnUpdate="0"/>
    <default field="relative_to_terrain" expression="" applyOnUpdate="0"/>
    <default field="relative_to_water" expression="" applyOnUpdate="0"/>
    <default field="last_modification_date" expression="" applyOnUpdate="0"/>
    <default field="updating_person" expression="" applyOnUpdate="0"/>
    <default field="reason_for_update" expression="" applyOnUpdate="0"/>
    <default field="lineage" expression="" applyOnUpdate="0"/>
    <default field="lod" expression="" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint constraints="3" notnull_strength="1" unique_strength="1" field="id" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="gmlid" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="gmlid_codespace" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="name" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="name_codespace" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="description" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="creation_date" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="termination_date" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="relative_to_terrain" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="relative_to_water" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="last_modification_date" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="updating_person" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="reason_for_update" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="lineage" exp_strength="0"/>
    <constraint constraints="0" notnull_strength="0" unique_strength="0" field="lod" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" field="id" exp=""/>
    <constraint desc="" field="gmlid" exp=""/>
    <constraint desc="" field="gmlid_codespace" exp=""/>
    <constraint desc="" field="name" exp=""/>
    <constraint desc="" field="name_codespace" exp=""/>
    <constraint desc="" field="description" exp=""/>
    <constraint desc="" field="creation_date" exp=""/>
    <constraint desc="" field="termination_date" exp=""/>
    <constraint desc="" field="relative_to_terrain" exp=""/>
    <constraint desc="" field="relative_to_water" exp=""/>
    <constraint desc="" field="last_modification_date" exp=""/>
    <constraint desc="" field="updating_person" exp=""/>
    <constraint desc="" field="reason_for_update" exp=""/>
    <constraint desc="" field="lineage" exp=""/>
    <constraint desc="" field="lod" exp=""/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorContainer name="Main Info" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Other" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorContainer name="Surface Relation" visibilityExpression="" columnCount="1" showLabel="1" groupBox="1" visibilityExpressionEnabled="0">
        <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
        <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
      </attributeEditorContainer>
    </attributeEditorContainer>
    <attributeEditorContainer name="Generic Attributes" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="cityobject_genericattrib_b6a28383_1622_4c51_bb21_290d61f06c78_cityobject_id_citydb_relief_feat_lod1_ed5529a5_6945_4841_abb9_d81767b43253_id" nmRelationId="" showLabel="0" label="Generic Attributes" forceSuppressFormPopup="0" relation="cityobject_genericattrib_b6a28383_1622_4c51_bb21_290d61f06c78_cityobject_id_citydb_relief_feat_lod1_ed5529a5_6945_4841_abb9_d81767b43253_id" relationWidgetTypeId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Relief Feature Attributes" visibilityExpression="" columnCount="2" showLabel="1" groupBox="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="lod" showLabel="1" index="14"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field name="class" editable="1"/>
    <field name="class_codespace" editable="1"/>
    <field name="creation_date" editable="0"/>
    <field name="crown_diameter" editable="1"/>
    <field name="crown_diameter_unit" editable="1"/>
    <field name="description" editable="1"/>
    <field name="function" editable="1"/>
    <field name="function_codespace" editable="1"/>
    <field name="gmlid" editable="0"/>
    <field name="gmlid_codespace" editable="1"/>
    <field name="height" editable="1"/>
    <field name="height_unit" editable="1"/>
    <field name="id" editable="0"/>
    <field name="last_modification_date" editable="1"/>
    <field name="lineage" editable="1"/>
    <field name="lod" editable="1"/>
    <field name="measured_height" editable="1"/>
    <field name="measured_height_unit" editable="1"/>
    <field name="name" editable="1"/>
    <field name="name_codespace" editable="1"/>
    <field name="reason_for_update" editable="1"/>
    <field name="relative_to_terrain" editable="1"/>
    <field name="relative_to_water" editable="1"/>
    <field name="roof_type" editable="1"/>
    <field name="roof_type_codespace" editable="1"/>
    <field name="species" editable="1"/>
    <field name="species_codespace" editable="1"/>
    <field name="storey_heights_above_ground" editable="1"/>
    <field name="storey_heights_ag_unit" editable="1"/>
    <field name="storey_heights_below_ground" editable="1"/>
    <field name="storey_heights_bg_unit" editable="1"/>
    <field name="storeys_above_ground" editable="1"/>
    <field name="storeys_below_ground" editable="1"/>
    <field name="termination_date" editable="0"/>
    <field name="trunk_diameter" editable="1"/>
    <field name="trunk_diameter_unit" editable="1"/>
    <field name="updating_person" editable="1"/>
    <field name="usage" editable="1"/>
    <field name="usage_codespace" editable="1"/>
    <field name="year_of_construction" editable="1"/>
    <field name="year_of_demolition" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="class" labelOnTop="0"/>
    <field name="class_codespace" labelOnTop="0"/>
    <field name="creation_date" labelOnTop="0"/>
    <field name="crown_diameter" labelOnTop="0"/>
    <field name="crown_diameter_unit" labelOnTop="0"/>
    <field name="description" labelOnTop="0"/>
    <field name="function" labelOnTop="0"/>
    <field name="function_codespace" labelOnTop="0"/>
    <field name="gmlid" labelOnTop="0"/>
    <field name="gmlid_codespace" labelOnTop="0"/>
    <field name="height" labelOnTop="0"/>
    <field name="height_unit" labelOnTop="0"/>
    <field name="id" labelOnTop="0"/>
    <field name="last_modification_date" labelOnTop="0"/>
    <field name="lineage" labelOnTop="0"/>
    <field name="lod" labelOnTop="0"/>
    <field name="measured_height" labelOnTop="0"/>
    <field name="measured_height_unit" labelOnTop="0"/>
    <field name="name" labelOnTop="0"/>
    <field name="name_codespace" labelOnTop="0"/>
    <field name="reason_for_update" labelOnTop="0"/>
    <field name="relative_to_terrain" labelOnTop="0"/>
    <field name="relative_to_water" labelOnTop="0"/>
    <field name="roof_type" labelOnTop="0"/>
    <field name="roof_type_codespace" labelOnTop="0"/>
    <field name="species" labelOnTop="0"/>
    <field name="species_codespace" labelOnTop="0"/>
    <field name="storey_heights_above_ground" labelOnTop="0"/>
    <field name="storey_heights_ag_unit" labelOnTop="0"/>
    <field name="storey_heights_below_ground" labelOnTop="0"/>
    <field name="storey_heights_bg_unit" labelOnTop="0"/>
    <field name="storeys_above_ground" labelOnTop="0"/>
    <field name="storeys_below_ground" labelOnTop="0"/>
    <field name="termination_date" labelOnTop="0"/>
    <field name="trunk_diameter" labelOnTop="0"/>
    <field name="trunk_diameter_unit" labelOnTop="0"/>
    <field name="updating_person" labelOnTop="0"/>
    <field name="usage" labelOnTop="0"/>
    <field name="usage_codespace" labelOnTop="0"/>
    <field name="year_of_construction" labelOnTop="0"/>
    <field name="year_of_demolition" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="class" reuseLastValue="0"/>
    <field name="class_codespace" reuseLastValue="0"/>
    <field name="creation_date" reuseLastValue="0"/>
    <field name="crown_diameter" reuseLastValue="0"/>
    <field name="crown_diameter_unit" reuseLastValue="0"/>
    <field name="description" reuseLastValue="0"/>
    <field name="function" reuseLastValue="0"/>
    <field name="function_codespace" reuseLastValue="0"/>
    <field name="gmlid" reuseLastValue="0"/>
    <field name="gmlid_codespace" reuseLastValue="1"/>
    <field name="height" reuseLastValue="0"/>
    <field name="height_unit" reuseLastValue="0"/>
    <field name="id" reuseLastValue="0"/>
    <field name="last_modification_date" reuseLastValue="0"/>
    <field name="lineage" reuseLastValue="0"/>
    <field name="lod" reuseLastValue="0"/>
    <field name="measured_height" reuseLastValue="0"/>
    <field name="measured_height_unit" reuseLastValue="0"/>
    <field name="name" reuseLastValue="0"/>
    <field name="name_codespace" reuseLastValue="0"/>
    <field name="reason_for_update" reuseLastValue="0"/>
    <field name="relative_to_terrain" reuseLastValue="0"/>
    <field name="relative_to_water" reuseLastValue="0"/>
    <field name="roof_type" reuseLastValue="0"/>
    <field name="roof_type_codespace" reuseLastValue="0"/>
    <field name="species" reuseLastValue="0"/>
    <field name="species_codespace" reuseLastValue="0"/>
    <field name="storey_heights_above_ground" reuseLastValue="0"/>
    <field name="storey_heights_ag_unit" reuseLastValue="0"/>
    <field name="storey_heights_below_ground" reuseLastValue="0"/>
    <field name="storey_heights_bg_unit" reuseLastValue="0"/>
    <field name="storeys_above_ground" reuseLastValue="0"/>
    <field name="storeys_below_ground" reuseLastValue="0"/>
    <field name="termination_date" reuseLastValue="0"/>
    <field name="trunk_diameter" reuseLastValue="0"/>
    <field name="trunk_diameter_unit" reuseLastValue="0"/>
    <field name="updating_person" reuseLastValue="0"/>
    <field name="usage" reuseLastValue="0"/>
    <field name="usage_codespace" reuseLastValue="0"/>
    <field name="year_of_construction" reuseLastValue="0"/>
    <field name="year_of_demolition" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>2</layerGeometryType>
</qgis>