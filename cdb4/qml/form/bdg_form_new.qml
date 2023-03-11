<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.16-Białowieża">
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
            <Option name="FilterExpression" type="QString" value="data_model = 'CityGML 2.0' AND name = 'RelativeToTerrainType'"/>
            <Option name="Key" type="QString" value="value"/>
            <Option name="Layer" type="QString" value="alderaan_v_enumeration_value_473d40e1_cc6e_449b_8f07_d60731011acd"/>
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
            <Option name="FilterExpression" type="QString" value="data_model = 'CityGML 2.0' AND name = 'RelativeToWaterType'"/>
            <Option name="Key" type="QString" value="value"/>
            <Option name="Layer" type="QString" value="alderaan_v_enumeration_value_473d40e1_cc6e_449b_8f07_d60731011acd"/>
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="class" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="class_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="function" configurationFlags="None">
      <editWidget type="List">
        <config>
          <Option type="Map">
            <Option name="EmptyIsEmptyArray" type="bool" value="false"/>
            <Option name="EmptyIsNull" type="bool" value="true"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="usage" configurationFlags="None">
      <editWidget type="List">
        <config>
          <Option type="Map">
            <Option name="EmptyIsEmptyArray" type="bool" value="false"/>
            <Option name="EmptyIsNull" type="bool" value="true"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="year_of_construction" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="yyyy"/>
            <Option name="field_format" type="QString" value="yyyy"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="year_of_demolition" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="yyyy"/>
            <Option name="field_format" type="QString" value="yyyy"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="roof_type_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="measured_height" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="measured_height_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storeys_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storeys_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_ag_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_bg_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="Database ID" field="id" index="0"/>
    <alias name="GML ID" field="gmlid" index="1"/>
    <alias name="GML codespace" field="gmlid_codespace" index="2"/>
    <alias name="Name" field="name" index="3"/>
    <alias name="Name codespace" field="name_codespace" index="4"/>
    <alias name="Description" field="description" index="5"/>
    <alias name="Creation date" field="creation_date" index="6"/>
    <alias name="Termination date" field="termination_date" index="7"/>
    <alias name="Relative to terrain" field="relative_to_terrain" index="8"/>
    <alias name="Relative to water" field="relative_to_water" index="9"/>
    <alias name="Last modification" field="last_modification_date" index="10"/>
    <alias name="Updating person" field="updating_person" index="11"/>
    <alias name="Reason for update" field="reason_for_update" index="12"/>
    <alias name="Lineage" field="lineage" index="13"/>
    <alias name="Class" field="class" index="14"/>
    <alias name="Codespace" field="class_codespace" index="15"/>
    <alias name="Function" field="function" index="16"/>
    <alias name="Codespace" field="function_codespace" index="17"/>
    <alias name="Usage" field="usage" index="18"/>
    <alias name="Codespace" field="usage_codespace" index="19"/>
    <alias name="Year of construction" field="year_of_construction" index="20"/>
    <alias name="Year of demolition" field="year_of_demolition" index="21"/>
    <alias name="Roof type" field="roof_type" index="22"/>
    <alias name="Codespace" field="roof_type_codespace" index="23"/>
    <alias name="Height" field="measured_height" index="24"/>
    <alias name="UoM" field="measured_height_unit" index="25"/>
    <alias name="Storeys above ground" field="storeys_above_ground" index="26"/>
    <alias name="Storeys below ground" field="storeys_below_ground" index="27"/>
    <alias name="Storey height above ground" field="storey_heights_above_ground" index="28"/>
    <alias name="UoM" field="storey_heights_ag_unit" index="29"/>
    <alias name="Storey height below ground" field="storey_heights_below_ground" index="30"/>
    <alias name="UoM" field="storey_heights_bg_unit" index="31"/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" field="id" expression=""/>
    <default applyOnUpdate="0" field="gmlid" expression=""/>
    <default applyOnUpdate="0" field="gmlid_codespace" expression=""/>
    <default applyOnUpdate="0" field="name" expression=""/>
    <default applyOnUpdate="0" field="name_codespace" expression=""/>
    <default applyOnUpdate="0" field="description" expression=""/>
    <default applyOnUpdate="0" field="creation_date" expression=""/>
    <default applyOnUpdate="0" field="termination_date" expression=""/>
    <default applyOnUpdate="0" field="relative_to_terrain" expression=""/>
    <default applyOnUpdate="0" field="relative_to_water" expression=""/>
    <default applyOnUpdate="0" field="last_modification_date" expression=""/>
    <default applyOnUpdate="0" field="updating_person" expression=""/>
    <default applyOnUpdate="0" field="reason_for_update" expression=""/>
    <default applyOnUpdate="0" field="lineage" expression=""/>
    <default applyOnUpdate="0" field="class" expression=""/>
    <default applyOnUpdate="0" field="class_codespace" expression=""/>
    <default applyOnUpdate="0" field="function" expression=""/>
    <default applyOnUpdate="0" field="function_codespace" expression=""/>
    <default applyOnUpdate="0" field="usage" expression=""/>
    <default applyOnUpdate="0" field="usage_codespace" expression=""/>
    <default applyOnUpdate="0" field="year_of_construction" expression=""/>
    <default applyOnUpdate="0" field="year_of_demolition" expression=""/>
    <default applyOnUpdate="0" field="roof_type" expression=""/>
    <default applyOnUpdate="0" field="roof_type_codespace" expression=""/>
    <default applyOnUpdate="0" field="measured_height" expression=""/>
    <default applyOnUpdate="0" field="measured_height_unit" expression=""/>
    <default applyOnUpdate="0" field="storeys_above_ground" expression=""/>
    <default applyOnUpdate="0" field="storeys_below_ground" expression=""/>
    <default applyOnUpdate="0" field="storey_heights_above_ground" expression=""/>
    <default applyOnUpdate="0" field="storey_heights_ag_unit" expression=""/>
    <default applyOnUpdate="0" field="storey_heights_below_ground" expression=""/>
    <default applyOnUpdate="0" field="storey_heights_bg_unit" expression=""/>
  </defaults>
  <constraints>
    <constraint constraints="3" unique_strength="1" exp_strength="0" field="id" notnull_strength="1"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="gmlid" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="gmlid_codespace" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="name" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="name_codespace" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="description" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="creation_date" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="termination_date" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="relative_to_terrain" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="relative_to_water" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="last_modification_date" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="updating_person" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="reason_for_update" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="lineage" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="class" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="class_codespace" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="function" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="function_codespace" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="usage" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="usage_codespace" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="year_of_construction" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="year_of_demolition" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="roof_type" notnull_strength="0"/>
    <constraint constraints="0" unique_strength="0" exp_strength="0" field="roof_type_codespace" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="measured_height" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="measured_height_unit" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="storeys_above_ground" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="storeys_below_ground" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="storey_heights_above_ground" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="storey_heights_ag_unit" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="storey_heights_below_ground" notnull_strength="0"/>
    <constraint constraints="4" unique_strength="0" exp_strength="1" field="storey_heights_bg_unit" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="id"/>
    <constraint desc="" exp="" field="gmlid"/>
    <constraint desc="" exp="" field="gmlid_codespace"/>
    <constraint desc="" exp="" field="name"/>
    <constraint desc="" exp="" field="name_codespace"/>
    <constraint desc="" exp="" field="description"/>
    <constraint desc="" exp="" field="creation_date"/>
    <constraint desc="" exp="" field="termination_date"/>
    <constraint desc="" exp="" field="relative_to_terrain"/>
    <constraint desc="" exp="" field="relative_to_water"/>
    <constraint desc="" exp="" field="last_modification_date"/>
    <constraint desc="" exp="" field="updating_person"/>
    <constraint desc="" exp="" field="reason_for_update"/>
    <constraint desc="" exp="" field="lineage"/>
    <constraint desc="" exp="" field="class"/>
    <constraint desc="" exp="" field="class_codespace"/>
    <constraint desc="" exp="" field="function"/>
    <constraint desc="" exp="" field="function_codespace"/>
    <constraint desc="" exp="" field="usage"/>
    <constraint desc="" exp="" field="usage_codespace"/>
    <constraint desc="" exp="" field="year_of_construction"/>
    <constraint desc="" exp="" field="year_of_demolition"/>
    <constraint desc="" exp="" field="roof_type"/>
    <constraint desc="" exp="" field="roof_type_codespace"/>
    <constraint desc="BOTH values must be either NULL or not NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)" field="measured_height"/>
    <constraint desc="BOTH values must be either NULL or not NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)" field="measured_height_unit"/>
    <constraint desc="Number must be >= 0" exp="(&quot;storeys_above_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_above_ground&quot; >= 0)" field="storeys_above_ground"/>
    <constraint desc="Number must be >= 0" exp="(&quot;storeys_below_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_below_ground&quot; >= 0)" field="storeys_below_ground"/>
    <constraint desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)" field="storey_heights_above_ground"/>
    <constraint desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)" field="storey_heights_ag_unit"/>
    <constraint desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)" field="storey_heights_below_ground"/>
    <constraint desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)" field="storey_heights_bg_unit"/>
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
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Relation to surface" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Ext ref (Name)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_ext_ref_name" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_ext_ref_name" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Ext ref (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_ext_ref_uri" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_ext_ref_uri" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Addresses" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_address_bdg" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_address_bdg" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature|ZoomToChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="Gen Attrib (String)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_string" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_string" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Integer)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_integer" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_integer" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Real)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_real" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_real" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Measure)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_measure" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_measure" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Date)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_date" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_date" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_uri" relationWidgetTypeId="relation_editor" relation="id_re_alderaan_bdg_lod0_dv_alderaan_gen_attrib_uri" label="Form detail views" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Blob)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="" relationWidgetTypeId="relation_editor" relation="" label="Gen Attrib (Blob) child form" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="Class" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="class" showLabel="1" index="14"/>
      <attributeEditorField name="class_codespace" showLabel="1" index="15"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Function" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="function" showLabel="1" index="16"/>
      <attributeEditorField name="function_codespace" showLabel="1" index="17"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Usage" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="usage" showLabel="1" index="18"/>
      <attributeEditorField name="usage_codespace" showLabel="1" index="19"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="Feature-specific attributes" visibilityExpressionEnabled="0" showLabel="1" groupBox="1" visibilityExpression="" columnCount="2">
      <attributeEditorField name="year_of_construction" showLabel="1" index="20"/>
      <attributeEditorField name="year_of_demolition" showLabel="1" index="21"/>
      <attributeEditorField name="storeys_above_ground" showLabel="1" index="26"/>
      <attributeEditorField name="storeys_below_ground" showLabel="1" index="27"/>
      <attributeEditorField name="measured_height" showLabel="1" index="24"/>
      <attributeEditorField name="measured_height_unit" showLabel="1" index="25"/>
      <attributeEditorField name="storey_heights_above_ground" showLabel="1" index="28"/>
      <attributeEditorField name="storey_heights_ag_unit" showLabel="1" index="29"/>
      <attributeEditorField name="storey_heights_below_ground" showLabel="1" index="30"/>
      <attributeEditorField name="storey_heights_bg_unit" showLabel="1" index="31"/>
      <attributeEditorField name="roof_type" showLabel="1" index="22"/>
      <attributeEditorField name="roof_type_codespace" showLabel="1" index="23"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field name="" editable="0"/>
    <field name="class" editable="1"/>
    <field name="class_codespace" editable="0"/>
    <field name="creation_date" editable="0"/>
    <field name="description" editable="1"/>
    <field name="function" editable="1"/>
    <field name="function_codespace" editable="0"/>
    <field name="gmlid" editable="0"/>
    <field name="gmlid_codespace" editable="0"/>
    <field name="id" editable="0"/>
    <field name="last_modification_date" editable="0"/>
    <field name="lineage" editable="0"/>
    <field name="measured_height" editable="1"/>
    <field name="measured_height_unit" editable="1"/>
    <field name="name" editable="1"/>
    <field name="name_codespace" editable="0"/>
    <field name="reason_for_update" editable="1"/>
    <field name="relative_to_terrain" editable="1"/>
    <field name="relative_to_water" editable="1"/>
    <field name="roof_type" editable="1"/>
    <field name="roof_type_codespace" editable="0"/>
    <field name="storey_heights_above_ground" editable="1"/>
    <field name="storey_heights_ag_unit" editable="1"/>
    <field name="storey_heights_below_ground" editable="1"/>
    <field name="storey_heights_bg_unit" editable="1"/>
    <field name="storeys_above_ground" editable="1"/>
    <field name="storeys_below_ground" editable="1"/>
    <field name="termination_date" editable="0"/>
    <field name="updating_person" editable="0"/>
    <field name="usage" editable="1"/>
    <field name="usage_codespace" editable="0"/>
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
    <field name="gmlid_codespace" reuseLastValue="0"/>
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
  <widgets/>
  <layerGeometryType>2</layerGeometryType>
</qgis>
