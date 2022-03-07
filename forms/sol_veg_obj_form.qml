<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.3-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="creation_date">
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
    <field configurationFlags="None" name="termination_date">
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
    <field configurationFlags="None" name="relative_to_terrain">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value=""/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value=""/>
            <Option name="LayerName" type="QString" value=""/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_water">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value=""/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value=""/>
            <Option name="LayerName" type="QString" value=""/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="last_modification_date">
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
    <field configurationFlags="None" name="updating_person">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="lineage">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="class">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value=""/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value=""/>
            <Option name="LayerName" type="QString" value=""/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="class_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="function">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="true"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value="codelist_name  =  'NL BAG Gebruiksdoel'"/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value=""/>
            <Option name="LayerName" type="QString" value=""/>
            <Option name="NofColumns" type="int" value="4"/>
            <Option name="OrderByValue" type="bool" value="true"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="function_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="usage">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="true"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value="codelist_name  =  'NL BAG Gebruiksdoel'"/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value=""/>
            <Option name="LayerName" type="QString" value=""/>
            <Option name="NofColumns" type="int" value="4"/>
            <Option name="OrderByValue" type="bool" value="true"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="usage_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="species">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="species_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="height">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="height_unit">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="trunk_diameter">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="trunk_diameter_unit">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="crown_diameter">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="crown_diameter_unit">
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
    <alias name="ID" index="0" field="id"/>
    <alias name="GML ID" index="1" field="gmlid"/>
    <alias name="GML codespace" index="2" field="gmlid_codespace"/>
    <alias name="Name" index="3" field="name"/>
    <alias name="Name codespace" index="4" field="name_codespace"/>
    <alias name="Description" index="5" field="description"/>
    <alias name="Creation Date" index="6" field="creation_date"/>
    <alias name="Termination Date" index="7" field="termination_date"/>
    <alias name="Relative to Terrain" index="8" field="relative_to_terrain"/>
    <alias name="Relative to Water" index="9" field="relative_to_water"/>
    <alias name="Latest Modification" index="10" field="last_modification_date"/>
    <alias name="Updating person" index="11" field="updating_person"/>
    <alias name="Updating Reason" index="12" field="reason_for_update"/>
    <alias name="Lineage" index="13" field="lineage"/>
    <alias name="Class" index="14" field="class"/>
    <alias name="Class codespace" index="15" field="class_codespace"/>
    <alias name="Function" index="16" field="function"/>
    <alias name="Function codespace" index="17" field="function_codespace"/>
    <alias name="Usage" index="18" field="usage"/>
    <alias name="Usage codespace" index="19" field="usage_codespace"/>
    <alias name="Species" index="20" field="species"/>
    <alias name="Species Codespace" index="21" field="species_codespace"/>
    <alias name="Height" index="22" field="height"/>
    <alias name="Height UoM" index="23" field="height_unit"/>
    <alias name="Trunk diameter" index="24" field="trunk_diameter"/>
    <alias name="Trunk diameter UoM" index="25" field="trunk_diameter_unit"/>
    <alias name="Crown diameter" index="26" field="crown_diameter"/>
    <alias name="Crown diameter UoM" index="27" field="crown_diameter_unit"/>
  </aliases>
  <defaults>
    <default expression="" applyOnUpdate="0" field="id"/>
    <default expression="" applyOnUpdate="0" field="gmlid"/>
    <default expression="" applyOnUpdate="0" field="gmlid_codespace"/>
    <default expression="" applyOnUpdate="0" field="name"/>
    <default expression="" applyOnUpdate="0" field="name_codespace"/>
    <default expression="" applyOnUpdate="0" field="description"/>
    <default expression="" applyOnUpdate="0" field="creation_date"/>
    <default expression="" applyOnUpdate="0" field="termination_date"/>
    <default expression="" applyOnUpdate="0" field="relative_to_terrain"/>
    <default expression="" applyOnUpdate="0" field="relative_to_water"/>
    <default expression="" applyOnUpdate="0" field="last_modification_date"/>
    <default expression="" applyOnUpdate="0" field="updating_person"/>
    <default expression="" applyOnUpdate="0" field="reason_for_update"/>
    <default expression="" applyOnUpdate="0" field="lineage"/>
    <default expression="" applyOnUpdate="0" field="class"/>
    <default expression="" applyOnUpdate="0" field="class_codespace"/>
    <default expression="" applyOnUpdate="0" field="function"/>
    <default expression="" applyOnUpdate="0" field="function_codespace"/>
    <default expression="" applyOnUpdate="0" field="usage"/>
    <default expression="" applyOnUpdate="0" field="usage_codespace"/>
    <default expression="" applyOnUpdate="0" field="species"/>
    <default expression="" applyOnUpdate="0" field="species_codespace"/>
    <default expression="" applyOnUpdate="0" field="height"/>
    <default expression="" applyOnUpdate="0" field="height_unit"/>
    <default expression="" applyOnUpdate="0" field="trunk_diameter"/>
    <default expression="" applyOnUpdate="0" field="trunk_diameter_unit"/>
    <default expression="" applyOnUpdate="0" field="crown_diameter"/>
    <default expression="" applyOnUpdate="0" field="crown_diameter_unit"/>
  </defaults>
  <constraints>
    <constraint unique_strength="1" notnull_strength="1" exp_strength="0" field="id" constraints="3"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="gmlid" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="gmlid_codespace" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="name" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="name_codespace" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="description" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="creation_date" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="termination_date" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="relative_to_terrain" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="relative_to_water" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="last_modification_date" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="updating_person" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="reason_for_update" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="lineage" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="class" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="class_codespace" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="function" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="function_codespace" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="usage" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="usage_codespace" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="species" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="species_codespace" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="height" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="height_unit" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="trunk_diameter" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="trunk_diameter_unit" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="crown_diameter" constraints="0"/>
    <constraint unique_strength="0" notnull_strength="0" exp_strength="0" field="crown_diameter_unit" constraints="0"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" desc="" field="id"/>
    <constraint exp="" desc="" field="gmlid"/>
    <constraint exp="" desc="" field="gmlid_codespace"/>
    <constraint exp="" desc="" field="name"/>
    <constraint exp="" desc="" field="name_codespace"/>
    <constraint exp="" desc="" field="description"/>
    <constraint exp="" desc="" field="creation_date"/>
    <constraint exp="" desc="" field="termination_date"/>
    <constraint exp="" desc="" field="relative_to_terrain"/>
    <constraint exp="" desc="" field="relative_to_water"/>
    <constraint exp="" desc="" field="last_modification_date"/>
    <constraint exp="" desc="" field="updating_person"/>
    <constraint exp="" desc="" field="reason_for_update"/>
    <constraint exp="" desc="" field="lineage"/>
    <constraint exp="" desc="" field="class"/>
    <constraint exp="" desc="" field="class_codespace"/>
    <constraint exp="" desc="" field="function"/>
    <constraint exp="" desc="" field="function_codespace"/>
    <constraint exp="" desc="" field="usage"/>
    <constraint exp="" desc="" field="usage_codespace"/>
    <constraint exp="" desc="" field="species"/>
    <constraint exp="" desc="" field="species_codespace"/>
    <constraint exp="" desc="" field="height"/>
    <constraint exp="" desc="" field="height_unit"/>
    <constraint exp="" desc="" field="trunk_diameter"/>
    <constraint exp="" desc="" field="trunk_diameter_unit"/>
    <constraint exp="" desc="" field="crown_diameter"/>
    <constraint exp="" desc="" field="crown_diameter_unit"/>
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
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="0" columnCount="1">
      <attributeEditorField name="id" index="0" showLabel="1"/>
      <attributeEditorField name="gmlid" index="1" showLabel="1"/>
      <attributeEditorField name="gmlid_codespace" index="2" showLabel="1"/>
      <attributeEditorField name="name" index="3" showLabel="1"/>
      <attributeEditorField name="name_codespace" index="4" showLabel="1"/>
      <attributeEditorField name="description" index="5" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="0" columnCount="1">
      <attributeEditorField name="creation_date" index="6" showLabel="1"/>
      <attributeEditorField name="termination_date" index="7" showLabel="1"/>
      <attributeEditorField name="last_modification_date" index="10" showLabel="1"/>
      <attributeEditorField name="updating_person" index="11" showLabel="1"/>
      <attributeEditorField name="reason_for_update" index="12" showLabel="1"/>
      <attributeEditorField name="lineage" index="13" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Other" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="0" columnCount="1">
      <attributeEditorContainer name="Surface Relation" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="1" columnCount="1">
        <attributeEditorField name="relative_to_terrain" index="8" showLabel="1"/>
        <attributeEditorField name="relative_to_water" index="9" showLabel="1"/>
      </attributeEditorContainer>
    </attributeEditorContainer>
    <attributeEditorContainer name="Generic Attributes" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="0" columnCount="1">
      <attributeEditorRelation nmRelationId="" relation="cityobject_genericattrib_f406227f_c7c8_4bbd_91ef_f00c08b66e1a_cityobject_id_citydb_solitary_vegetat_object_lod3_implicitrep_6f238660_14fc_4634_88e0_6e7e45c39925_id" relationWidgetTypeId="relation_editor" forceSuppressFormPopup="0" name="cityobject_genericattrib_f406227f_c7c8_4bbd_91ef_f00c08b66e1a_cityobject_id_citydb_solitary_vegetat_object_lod3_implicitrep_6f238660_14fc_4634_88e0_6e7e45c39925_id" label="Generic Attributes" showLabel="0">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="AllButtons"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Solitary Vegetation Object Attributes" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="1" columnCount="2">
      <attributeEditorField name="species" index="20" showLabel="1"/>
      <attributeEditorField name="species_codespace" index="21" showLabel="1"/>
      <attributeEditorField name="height" index="22" showLabel="1"/>
      <attributeEditorField name="height_unit" index="23" showLabel="1"/>
      <attributeEditorField name="trunk_diameter" index="24" showLabel="1"/>
      <attributeEditorField name="trunk_diameter_unit" index="25" showLabel="1"/>
      <attributeEditorField name="crown_diameter" index="26" showLabel="1"/>
      <attributeEditorField name="crown_diameter_unit" index="27" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Class" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="0" columnCount="1">
      <attributeEditorField name="class" index="14" showLabel="1"/>
      <attributeEditorField name="class_codespace" index="15" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Function" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="0" columnCount="1">
      <attributeEditorField name="function" index="16" showLabel="1"/>
      <attributeEditorField name="function_codespace" index="17" showLabel="1"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Usage" visibilityExpressionEnabled="0" visibilityExpression="" showLabel="1" groupBox="0" columnCount="1">
      <attributeEditorField name="usage" index="18" showLabel="1"/>
      <attributeEditorField name="usage_codespace" index="19" showLabel="1"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="class"/>
    <field editable="1" name="class_codespace"/>
    <field editable="0" name="creation_date"/>
    <field editable="1" name="crown_diameter"/>
    <field editable="1" name="crown_diameter_unit"/>
    <field editable="1" name="description"/>
    <field editable="1" name="function"/>
    <field editable="1" name="function_codespace"/>
    <field editable="0" name="gmlid"/>
    <field editable="1" name="gmlid_codespace"/>
    <field editable="1" name="height"/>
    <field editable="1" name="height_unit"/>
    <field editable="0" name="id"/>
    <field editable="1" name="last_modification_date"/>
    <field editable="1" name="lineage"/>
    <field editable="1" name="measured_height"/>
    <field editable="1" name="measured_height_unit"/>
    <field editable="1" name="name"/>
    <field editable="1" name="name_codespace"/>
    <field editable="1" name="reason_for_update"/>
    <field editable="1" name="relative_to_terrain"/>
    <field editable="1" name="relative_to_water"/>
    <field editable="1" name="roof_type"/>
    <field editable="1" name="roof_type_codespace"/>
    <field editable="1" name="species"/>
    <field editable="1" name="species_codespace"/>
    <field editable="1" name="storey_heights_above_ground"/>
    <field editable="1" name="storey_heights_ag_unit"/>
    <field editable="1" name="storey_heights_below_ground"/>
    <field editable="1" name="storey_heights_bg_unit"/>
    <field editable="1" name="storeys_above_ground"/>
    <field editable="1" name="storeys_below_ground"/>
    <field editable="0" name="termination_date"/>
    <field editable="1" name="trunk_diameter"/>
    <field editable="1" name="trunk_diameter_unit"/>
    <field editable="1" name="updating_person"/>
    <field editable="1" name="usage"/>
    <field editable="1" name="usage_codespace"/>
    <field editable="1" name="year_of_construction"/>
    <field editable="1" name="year_of_demolition"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="0" name="class"/>
    <field labelOnTop="0" name="class_codespace"/>
    <field labelOnTop="0" name="creation_date"/>
    <field labelOnTop="0" name="crown_diameter"/>
    <field labelOnTop="0" name="crown_diameter_unit"/>
    <field labelOnTop="0" name="description"/>
    <field labelOnTop="0" name="function"/>
    <field labelOnTop="0" name="function_codespace"/>
    <field labelOnTop="0" name="gmlid"/>
    <field labelOnTop="0" name="gmlid_codespace"/>
    <field labelOnTop="0" name="height"/>
    <field labelOnTop="0" name="height_unit"/>
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
    <field labelOnTop="0" name="species"/>
    <field labelOnTop="0" name="species_codespace"/>
    <field labelOnTop="0" name="storey_heights_above_ground"/>
    <field labelOnTop="0" name="storey_heights_ag_unit"/>
    <field labelOnTop="0" name="storey_heights_below_ground"/>
    <field labelOnTop="0" name="storey_heights_bg_unit"/>
    <field labelOnTop="0" name="storeys_above_ground"/>
    <field labelOnTop="0" name="storeys_below_ground"/>
    <field labelOnTop="0" name="termination_date"/>
    <field labelOnTop="0" name="trunk_diameter"/>
    <field labelOnTop="0" name="trunk_diameter_unit"/>
    <field labelOnTop="0" name="updating_person"/>
    <field labelOnTop="0" name="usage"/>
    <field labelOnTop="0" name="usage_codespace"/>
    <field labelOnTop="0" name="year_of_construction"/>
    <field labelOnTop="0" name="year_of_demolition"/>
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
