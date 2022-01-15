<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.1-Białowieża" styleCategories="Forms">
  <fieldConfiguration>
    <field name="id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name_codespace">
      <editWidget type="Hidden">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="description">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="creation_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="termination_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_terrain">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="code_value" type="QString"/>
            <Option name="Layer" value="lu_relative_to_terrain_410c9956_9635_4cfa_8d35_9f272205fd65" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="code_value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_water">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="code_value" type="QString"/>
            <Option name="Layer" value="lu_relative_to_water_a527b29c_2c2a_4b8f_9c2f_86dfe39057a7" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="code_value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="updating_person">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="reason_for_update">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="lineage">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="class">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="Description" value="" type="QString"/>
            <Option name="FilterExpression" value=" &quot;codelist_name&quot;  =  'TUD 3DGeoInfo 3DBAG' " type="QString"/>
            <Option name="Key" value="code_value" type="QString"/>
            <Option name="Layer" value="lu_building_class_c19e74da_f53d_4c4c_a420_43b7f2ae4e13" type="QString"/>
            <Option name="LayerName" value="lu_building_class" type="QString"/>
            <Option name="LayerProviderName" value="postgres" type="QString"/>
            <Option name="LayerSource" value="dbname='qgis_test' host=3dcities.bk.tudelft.nl port=5810 user='qgis_test_user' sslmode=disable key='code_value' estimatedmetadata=true checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_building_class&quot;" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="code_name" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="class_codespace">
      <editWidget type="Hidden">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="function">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="true" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="Description" value="" type="QString"/>
            <Option name="FilterExpression" value=" &quot;codelist_name&quot;  =  'NL BAG Gebruiksdoel' " type="QString"/>
            <Option name="Key" value="code_value" type="QString"/>
            <Option name="Layer" value="lu_building_function_usage_149bb804_f8a6_458d_8411_0f94740abf27" type="QString"/>
            <Option name="LayerName" value="lu_building_function_usage" type="QString"/>
            <Option name="LayerProviderName" value="postgres" type="QString"/>
            <Option name="LayerSource" value="dbname='qgis_test' host=3dcities.bk.tudelft.nl port=5810 user='qgis_test_user' sslmode=disable key='code_value' estimatedmetadata=true checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_building_function_usage&quot;" type="QString"/>
            <Option name="NofColumns" value="4" type="int"/>
            <Option name="OrderByValue" value="true" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="code_name" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function_codespace">
      <editWidget type="Hidden">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="usage">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="true" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="Description" value="" type="QString"/>
            <Option name="FilterExpression" value=" &quot;codelist_name&quot;  =  'NL BAG Gebruiksdoel' " type="QString"/>
            <Option name="Key" value="code_value" type="QString"/>
            <Option name="Layer" value="lu_building_function_usage_149bb804_f8a6_458d_8411_0f94740abf27" type="QString"/>
            <Option name="LayerName" value="lu_building_function_usage" type="QString"/>
            <Option name="LayerProviderName" value="postgres" type="QString"/>
            <Option name="LayerSource" value="dbname='qgis_test' host=3dcities.bk.tudelft.nl port=5810 user='qgis_test_user' sslmode=disable key='code_value' estimatedmetadata=true checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_building_function_usage&quot;" type="QString"/>
            <Option name="NofColumns" value="4" type="int"/>
            <Option name="OrderByValue" value="true" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="code_name" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage_codespace">
      <editWidget type="Hidden">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="year_of_construction">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd/MM/yyyy" type="QString"/>
            <Option name="field_format" value="dd/MM/yyyy" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="year_of_demolition">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd/MM/yyyy" type="QString"/>
            <Option name="field_format" value="dd/MM/yyyy" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type_codespace">
      <editWidget type="Hidden">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="measured_height">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="measured_height_unit">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storeys_above_ground">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storeys_below_ground">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_above_ground">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_ag_unit">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_below_ground">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_bg_unit">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" value="false" type="bool"/>
            <Option name="UseHtml" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
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
    <attributeEditorContainer name="Main info" showLabel="1" columnCount="3" visibilityExpression="" groupBox="0" backgroundColor="#ffd5d5" visibilityExpressionEnabled="0">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database_info" showLabel="1" columnCount="3" visibilityExpression="" groupBox="0" backgroundColor="#fdbf6f" visibilityExpressionEnabled="0">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Relative to:" showLabel="1" columnCount="2" visibilityExpression="" groupBox="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Land Use" showLabel="1" columnCount="1" visibilityExpression="" groupBox="1" backgroundColor="#afe5ff" visibilityExpressionEnabled="0">
      <attributeEditorField name="class" showLabel="1" index="14"/>
      <attributeEditorField name="function" showLabel="1" index="16"/>
      <attributeEditorField name="usage" showLabel="1" index="18"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Physical data" showLabel="1" columnCount="2" visibilityExpression="" groupBox="1" backgroundColor="#a4d477" visibilityExpressionEnabled="0">
      <attributeEditorField name="roof_type" showLabel="1" index="22"/>
      <attributeEditorField name="measured_height" showLabel="1" index="24"/>
      <attributeEditorField name="measured_height_unit" showLabel="1" index="25"/>
      <attributeEditorField name="storey_heights_above_ground" showLabel="1" index="28"/>
      <attributeEditorField name="storey_heights_ag_unit" showLabel="1" index="29"/>
      <attributeEditorField name="storey_heights_below_ground" showLabel="1" index="30"/>
      <attributeEditorField name="storey_heights_bg_unit" showLabel="1" index="31"/>
      <attributeEditorField name="year_of_construction" showLabel="1" index="20"/>
      <attributeEditorField name="year_of_demolition" showLabel="1" index="21"/>
      <attributeEditorField name="storeys_above_ground" showLabel="1" index="26"/>
      <attributeEditorField name="storeys_below_ground" showLabel="1" index="27"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field name="class" editable="1"/>
    <field name="class_codespace" editable="1"/>
    <field name="creation_date" editable="0"/>
    <field name="description" editable="1"/>
    <field name="function" editable="1"/>
    <field name="function_codespace" editable="1"/>
    <field name="gmlid" editable="0"/>
    <field name="gmlid_codespace" editable="1"/>
    <field name="id" editable="0"/>
    <field name="last_modification_date" editable="1"/>
    <field name="lineage" editable="1"/>
    <field name="measured_height" editable="1"/>
    <field name="measured_height_unit" editable="1"/>
    <field name="name" editable="1"/>
    <field name="name_codespace" editable="1"/>
    <field name="reason_for_update" editable="1"/>
    <field name="relative_to_terrain" editable="1"/>
    <field name="relative_to_water" editable="1"/>
    <field name="roof_type" editable="1"/>
    <field name="roof_type_codespace" editable="1"/>
    <field name="storey_heights_above_ground" editable="1"/>
    <field name="storey_heights_ag_unit" editable="1"/>
    <field name="storey_heights_below_ground" editable="1"/>
    <field name="storey_heights_bg_unit" editable="1"/>
    <field name="storeys_above_ground" editable="1"/>
    <field name="storeys_below_ground" editable="1"/>
    <field name="termination_date" editable="0"/>
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
    <field name="description" labelOnTop="0"/>
    <field name="function" labelOnTop="0"/>
    <field name="function_codespace" labelOnTop="0"/>
    <field name="gmlid" labelOnTop="0"/>
    <field name="gmlid_codespace" labelOnTop="0"/>
    <field name="id" labelOnTop="0"/>
    <field name="last_modification_date" labelOnTop="0"/>
    <field name="lineage" labelOnTop="0"/>
    <field name="measured_height" labelOnTop="0"/>
    <field name="measured_height_unit" labelOnTop="0"/>
    <field name="name" labelOnTop="0"/>
    <field name="name_codespace" labelOnTop="0"/>
    <field name="reason_for_update" labelOnTop="0"/>
    <field name="relative_to_terrain" labelOnTop="0"/>
    <field name="relative_to_water" labelOnTop="0"/>
    <field name="roof_type" labelOnTop="0"/>
    <field name="roof_type_codespace" labelOnTop="0"/>
    <field name="storey_heights_above_ground" labelOnTop="0"/>
    <field name="storey_heights_ag_unit" labelOnTop="0"/>
    <field name="storey_heights_below_ground" labelOnTop="0"/>
    <field name="storey_heights_bg_unit" labelOnTop="0"/>
    <field name="storeys_above_ground" labelOnTop="0"/>
    <field name="storeys_below_ground" labelOnTop="0"/>
    <field name="termination_date" labelOnTop="0"/>
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
    <field name="description" reuseLastValue="0"/>
    <field name="function" reuseLastValue="0"/>
    <field name="function_codespace" reuseLastValue="0"/>
    <field name="gmlid" reuseLastValue="0"/>
    <field name="gmlid_codespace" reuseLastValue="1"/>
    <field name="id" reuseLastValue="0"/>
    <field name="last_modification_date" reuseLastValue="0"/>
    <field name="lineage" reuseLastValue="0"/>
    <field name="measured_height" reuseLastValue="0"/>
    <field name="measured_height_unit" reuseLastValue="0"/>
    <field name="name" reuseLastValue="0"/>
    <field name="name_codespace" reuseLastValue="0"/>
    <field name="reason_for_update" reuseLastValue="0"/>
    <field name="relative_to_terrain" reuseLastValue="0"/>
    <field name="relative_to_water" reuseLastValue="0"/>
    <field name="roof_type" reuseLastValue="0"/>
    <field name="roof_type_codespace" reuseLastValue="0"/>
    <field name="storey_heights_above_ground" reuseLastValue="0"/>
    <field name="storey_heights_ag_unit" reuseLastValue="0"/>
    <field name="storey_heights_below_ground" reuseLastValue="0"/>
    <field name="storey_heights_bg_unit" reuseLastValue="0"/>
    <field name="storeys_above_ground" reuseLastValue="0"/>
    <field name="storeys_below_ground" reuseLastValue="0"/>
    <field name="termination_date" reuseLastValue="0"/>
    <field name="updating_person" reuseLastValue="0"/>
    <field name="usage" reuseLastValue="0"/>
    <field name="usage_codespace" reuseLastValue="0"/>
    <field name="year_of_construction" reuseLastValue="0"/>
    <field name="year_of_demolition" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets>
    <widget name="cityobject_cityobject_id_citydb_bui_id">
      <config type="Map">
        <Option name="force-suppress-popup" value="false" type="bool"/>
        <Option name="nm-rel" type="invalid"/>
      </config>
    </widget>
    <widget name="cityobject_cityobject_id_citydb_bui_id_1">
      <config type="Map">
        <Option name="force-suppress-popup" value="false" type="bool"/>
        <Option name="nm-rel" type="invalid"/>
      </config>
    </widget>
    <widget name="cityobject_genericattrib_30880a40_c0cb_4b81_a457_a9d3a4ef765e_cityobject_id_citydb_building_lod0_footprint_cf26363d_f664_4468_9b0f_8ef82c8fb763_id">
      <config type="Map">
        <Option name="force-suppress-popup" value="false" type="bool"/>
        <Option name="nm-rel" type="invalid"/>
      </config>
    </widget>
    <widget name="cityobject_genericattrib_30880a40_c0cb_4b81_a457_a9d3a4ef765e_cityobject_id_citydb_building_lod0_footprint_fcbf7680_9aec_493a_8f15_5f11a712304e_id">
      <config type="Map">
        <Option name="force-suppress-popup" value="false" type="bool"/>
        <Option name="nm-rel" type="invalid"/>
      </config>
    </widget>
    <widget name="cityobject_genericattrib_30880a40_c0cb_4b81_a457_a9d3a4ef765e_cityobject_id_citydb_building_lod0_roofedge_616c916c_8013_4b86_b292_5f4b0e1c9b17_id">
      <config type="Map">
        <Option name="force-suppress-popup" value="false" type="bool"/>
        <Option name="nm-rel" type="invalid"/>
      </config>
    </widget>
    <widget name="cityobject_genericattrib_30880a40_c0cb_4b81_a457_a9d3a4ef765e_cityobject_id_citydb_building_lod0_roofedge_78d216a0_bb69_4c24_9fab_49d1881ebd59_id">
      <config type="Map">
        <Option name="force-suppress-popup" value="false" type="bool"/>
        <Option name="nm-rel" type="invalid"/>
      </config>
    </widget>
  </widgets>
  <layerGeometryType>2</layerGeometryType>
</qgis>
