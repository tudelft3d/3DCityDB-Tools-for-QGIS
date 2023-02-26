<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.16-Białowieża" styleCategories="Fields|Forms">
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
    <field configurationFlags="None" name="parent_genattrib_id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="root_genattrib_id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="attrname">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="value">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" value="true" name="allow_null"/>
            <Option type="bool" value="true" name="calendar_popup"/>
            <Option type="QString" value="dd/MM/yyyy HH:mm:ss" name="display_format"/>
            <Option type="QString" value="dd/MM/yyyy HH:mm:ss" name="field_format"/>
            <Option type="bool" value="false" name="field_iso_format"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="cityobject_id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" value="false" name="IsMultiline"/>
            <Option type="bool" value="false" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" name="Database ID" index="0"/>
    <alias field="parent_genattrib_id" name="" index="1"/>
    <alias field="root_genattrib_id" name="" index="2"/>
    <alias field="attrname" name="Attribute name" index="3"/>
    <alias field="value" name="Value" index="4"/>
    <alias field="cityobject_id" name="Cityobject ID" index="5"/>
  </aliases>
  <defaults>
    <default field="id" applyOnUpdate="0" expression=""/>
    <default field="parent_genattrib_id" applyOnUpdate="0" expression=""/>
    <default field="root_genattrib_id" applyOnUpdate="0" expression=""/>
    <default field="attrname" applyOnUpdate="0" expression=""/>
    <default field="value" applyOnUpdate="0" expression=""/>
    <default field="cityobject_id" applyOnUpdate="0" expression=""/>
  </defaults>
  <constraints>
    <constraint field="id" notnull_strength="1" exp_strength="0" unique_strength="1" constraints="3"/>
    <constraint field="parent_genattrib_id" notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0"/>
    <constraint field="root_genattrib_id" notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0"/>
    <constraint field="attrname" notnull_strength="1" exp_strength="0" unique_strength="0" constraints="1"/>
    <constraint field="value" notnull_strength="1" exp_strength="0" unique_strength="0" constraints="1"/>
    <constraint field="cityobject_id" notnull_strength="0" exp_strength="0" unique_strength="0" constraints="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" field="id" exp=""/>
    <constraint desc="" field="parent_genattrib_id" exp=""/>
    <constraint desc="" field="root_genattrib_id" exp=""/>
    <constraint desc="" field="attrname" exp=""/>
    <constraint desc="" field="value" exp=""/>
    <constraint desc="" field="cityobject_id" exp=""/>
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
    <attributeEditorField showLabel="1" name="id" index="0"/>
    <attributeEditorField showLabel="1" name="attrname" index="3"/>
    <attributeEditorField showLabel="1" name="value" index="4"/>
    <attributeEditorField showLabel="1" name="cityobject_id" index="5"/>
  </attributeEditorForm>
  <editable>
    <field name="attrname" editable="1"/>
    <field name="cityobject_id" editable="0"/>
    <field name="id" editable="0"/>
    <field name="parent_genattrib_id" editable="0"/>
    <field name="root_genattrib_id" editable="0"/>
    <field name="value" editable="1"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="0" name="attrname"/>
    <field labelOnTop="0" name="cityobject_id"/>
    <field labelOnTop="0" name="id"/>
    <field labelOnTop="0" name="parent_genattrib_id"/>
    <field labelOnTop="0" name="root_genattrib_id"/>
    <field labelOnTop="0" name="value"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="attrname" reuseLastValue="0"/>
    <field name="cityobject_id" reuseLastValue="0"/>
    <field name="id" reuseLastValue="0"/>
    <field name="parent_genattrib_id" reuseLastValue="0"/>
    <field name="root_genattrib_id" reuseLastValue="0"/>
    <field name="value" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
