<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.3-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="creation_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd-MM-yyyy HH:mm:ss" name="display_format"/>
            <Option type="QString" value="dd-MM-yyyy HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="termination_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd-MM-yyyy HH:mm:ss" name="display_format"/>
            <Option type="QString" value="dd-MM-yyyy HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_terrain">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="QString" value="" name="FilterExpression"/>
            <Option type="QString" value="code_value" name="Key"/>
            <Option type="QString" value="lu_relative_to_terrain_1b88274c_4408_4144_b336_9c52bfe0330c" name="Layer"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="code_name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_water">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="AllowMulti"/>
            <Option type="bool" value="true" name="AllowNull"/>
            <Option type="QString" value="" name="FilterExpression"/>
            <Option type="QString" value="code_value" name="Key"/>
            <Option type="QString" value="lu_relative_to_water_0d8964c4_d81d_4404_93f2_c352dfbf0f80" name="Layer"/>
            <Option type="int" value="1" name="NofColumns"/>
            <Option type="bool" value="false" name="OrderByValue"/>
            <Option type="bool" value="false" name="UseCompleter"/>
            <Option type="QString" value="code_name" name="Value"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="last_modification_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd-MM-yyyy HH:mm:ss" name="display_format"/>
            <Option type="QString" value="dd-MM-yyyy HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="updating_person">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="lineage">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="building_id">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" index="0" name="ID"/>
    <alias field="gmlid" index="1" name="GML ID"/>
    <alias field="gmlid_codespace" index="2" name="GML codespace"/>
    <alias field="name" index="3" name="Name"/>
    <alias field="name_codespace" index="4" name="Name codespace"/>
    <alias field="description" index="5" name="Description"/>
    <alias field="creation_date" index="6" name="Creation Date"/>
    <alias field="termination_date" index="7" name="Termination Date"/>
    <alias field="relative_to_terrain" index="8" name="Relative to Terrain"/>
    <alias field="relative_to_water" index="9" name="Relative to Water"/>
    <alias field="last_modification_date" index="10" name="Latest Modification"/>
    <alias field="updating_person" index="11" name="Updating person"/>
    <alias field="reason_for_update" index="12" name="Updating Reason"/>
    <alias field="lineage" index="13" name="Lineage"/>
    <alias field="building_id" index="14" name=""/>
  </aliases>
  <defaults>
    <default expression="" field="id" applyOnUpdate="0"/>
    <default expression="" field="gmlid" applyOnUpdate="0"/>
    <default expression="" field="gmlid_codespace" applyOnUpdate="0"/>
    <default expression="" field="name" applyOnUpdate="0"/>
    <default expression="" field="name_codespace" applyOnUpdate="0"/>
    <default expression="" field="description" applyOnUpdate="0"/>
    <default expression="" field="creation_date" applyOnUpdate="0"/>
    <default expression="" field="termination_date" applyOnUpdate="0"/>
    <default expression="" field="relative_to_terrain" applyOnUpdate="0"/>
    <default expression="" field="relative_to_water" applyOnUpdate="0"/>
    <default expression="" field="last_modification_date" applyOnUpdate="0"/>
    <default expression="" field="updating_person" applyOnUpdate="0"/>
    <default expression="" field="reason_for_update" applyOnUpdate="0"/>
    <default expression="" field="lineage" applyOnUpdate="0"/>
    <default expression="" field="building_id" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" field="id" constraints="3" unique_strength="1" exp_strength="0"/>
    <constraint notnull_strength="0" field="gmlid" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="gmlid_codespace" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="name" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="name_codespace" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="description" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="creation_date" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="termination_date" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="relative_to_terrain" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="relative_to_water" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="last_modification_date" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="updating_person" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="reason_for_update" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="lineage" constraints="0" unique_strength="0" exp_strength="0"/>
    <constraint notnull_strength="0" field="building_id" constraints="0" unique_strength="0" exp_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" field="id" desc=""/>
    <constraint exp="" field="gmlid" desc=""/>
    <constraint exp="" field="gmlid_codespace" desc=""/>
    <constraint exp="" field="name" desc=""/>
    <constraint exp="" field="name_codespace" desc=""/>
    <constraint exp="" field="description" desc=""/>
    <constraint exp="" field="creation_date" desc=""/>
    <constraint exp="" field="termination_date" desc=""/>
    <constraint exp="" field="relative_to_terrain" desc=""/>
    <constraint exp="" field="relative_to_water" desc=""/>
    <constraint exp="" field="last_modification_date" desc=""/>
    <constraint exp="" field="updating_person" desc=""/>
    <constraint exp="" field="reason_for_update" desc=""/>
    <constraint exp="" field="lineage" desc=""/>
    <constraint exp="" field="building_id" desc=""/>
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
    <attributeEditorContainer showLabel="1" groupBox="0" columnCount="1" visibilityExpressionEnabled="0" name="Main Info" visibilityExpression="">
      <attributeEditorField showLabel="1" index="0" name="id"/>
      <attributeEditorField showLabel="1" index="1" name="gmlid"/>
      <attributeEditorField showLabel="1" index="2" name="gmlid_codespace"/>
      <attributeEditorField showLabel="1" index="3" name="name"/>
      <attributeEditorField showLabel="1" index="4" name="name_codespace"/>
      <attributeEditorField showLabel="1" index="5" name="description"/>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" groupBox="0" columnCount="1" visibilityExpressionEnabled="0" name="Database Info" visibilityExpression="">
      <attributeEditorField showLabel="1" index="6" name="creation_date"/>
      <attributeEditorField showLabel="1" index="7" name="termination_date"/>
      <attributeEditorField showLabel="1" index="10" name="last_modification_date"/>
      <attributeEditorField showLabel="1" index="11" name="updating_person"/>
      <attributeEditorField showLabel="1" index="12" name="reason_for_update"/>
      <attributeEditorField showLabel="1" index="13" name="lineage"/>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" groupBox="0" columnCount="1" visibilityExpressionEnabled="0" name="Other" visibilityExpression="">
      <attributeEditorContainer showLabel="1" groupBox="1" columnCount="1" visibilityExpressionEnabled="0" name="Surface Relation" visibilityExpression="">
        <attributeEditorField showLabel="1" index="8" name="relative_to_terrain"/>
        <attributeEditorField showLabel="1" index="9" name="relative_to_water"/>
      </attributeEditorContainer>
    </attributeEditorContainer>
    <attributeEditorContainer showLabel="1" groupBox="0" columnCount="1" visibilityExpressionEnabled="0" name="Generic Attributes" visibilityExpression="">
      <attributeEditorRelation relationWidgetTypeId="" relation="cityobject_genericattrib_5e19b53c_46ce_4bef_8f55_83981cce0439_cityobject_id_citydb_bdg_part_lod2_groundsurf_2b75f660_3a32_442c_be16_9e8651a4e2b2_id" label="Generic Attributes" showLabel="0" forceSuppressFormPopup="0" nmRelationId="" name="cityobject_genericattrib_5e19b53c_46ce_4bef_8f55_83981cce0439_cityobject_id_citydb_bdg_part_lod2_groundsurf_2b75f660_3a32_442c_be16_9e8651a4e2b2_id">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field name="building_id" editable="1"/>
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
    <field labelOnTop="0" name="building_id"/>
    <field labelOnTop="0" name="class"/>
    <field labelOnTop="0" name="class_codespace"/>
    <field labelOnTop="0" name="creation_date"/>
    <field labelOnTop="0" name="description"/>
    <field labelOnTop="0" name="function"/>
    <field labelOnTop="0" name="function_codespace"/>
    <field labelOnTop="0" name="gmlid"/>
    <field labelOnTop="0" name="gmlid_codespace"/>
    <field labelOnTop="0" name="id"/>
    <field labelOnTop="0" name="last_modification_date"/>
    <field labelOnTop="0" name="lineage"/>
    <field labelOnTop="0" name="measured_height"/>
    <field labelOnTop="0" name="measured_height_unit"/>
    <field labelOnTop="0" name="name"/>
    <field labelOnTop="0" name="name_codespace"/>
    <field labelOnTop="0" name="reason_for_update"/>
    <field labelOnTop="0" name="relative_to_terrain"/>
    <field labelOnTop="0" name="relative_to_water"/>
    <field labelOnTop="0" name="roof_type"/>
    <field labelOnTop="0" name="roof_type_codespace"/>
    <field labelOnTop="0" name="storey_heights_above_ground"/>
    <field labelOnTop="0" name="storey_heights_ag_unit"/>
    <field labelOnTop="0" name="storey_heights_below_ground"/>
    <field labelOnTop="0" name="storey_heights_bg_unit"/>
    <field labelOnTop="0" name="storeys_above_ground"/>
    <field labelOnTop="0" name="storeys_below_ground"/>
    <field labelOnTop="0" name="termination_date"/>
    <field labelOnTop="0" name="updating_person"/>
    <field labelOnTop="0" name="usage"/>
    <field labelOnTop="0" name="usage_codespace"/>
    <field labelOnTop="0" name="year_of_construction"/>
    <field labelOnTop="0" name="year_of_demolition"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="building_id"/>
    <field reuseLastValue="0" name="class"/>
    <field reuseLastValue="0" name="class_codespace"/>
    <field reuseLastValue="0" name="creation_date"/>
    <field reuseLastValue="0" name="description"/>
    <field reuseLastValue="0" name="function"/>
    <field reuseLastValue="0" name="function_codespace"/>
    <field reuseLastValue="0" name="gmlid"/>
    <field reuseLastValue="1" name="gmlid_codespace"/>
    <field reuseLastValue="0" name="id"/>
    <field reuseLastValue="0" name="last_modification_date"/>
    <field reuseLastValue="0" name="lineage"/>
    <field reuseLastValue="0" name="measured_height"/>
    <field reuseLastValue="0" name="measured_height_unit"/>
    <field reuseLastValue="0" name="name"/>
    <field reuseLastValue="0" name="name_codespace"/>
    <field reuseLastValue="0" name="reason_for_update"/>
    <field reuseLastValue="0" name="relative_to_terrain"/>
    <field reuseLastValue="0" name="relative_to_water"/>
    <field reuseLastValue="0" name="roof_type"/>
    <field reuseLastValue="0" name="roof_type_codespace"/>
    <field reuseLastValue="0" name="storey_heights_above_ground"/>
    <field reuseLastValue="0" name="storey_heights_ag_unit"/>
    <field reuseLastValue="0" name="storey_heights_below_ground"/>
    <field reuseLastValue="0" name="storey_heights_bg_unit"/>
    <field reuseLastValue="0" name="storeys_above_ground"/>
    <field reuseLastValue="0" name="storeys_below_ground"/>
    <field reuseLastValue="0" name="termination_date"/>
    <field reuseLastValue="0" name="updating_person"/>
    <field reuseLastValue="0" name="usage"/>
    <field reuseLastValue="0" name="usage_codespace"/>
    <field reuseLastValue="0" name="year_of_construction"/>
    <field reuseLastValue="0" name="year_of_demolition"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>2</layerGeometryType>
</qgis>
