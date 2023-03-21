<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.16-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="attrname">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="value">
      <editWidget type="Binary">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="cityobject_id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" index="0" name="Database ID"/>
    <alias field="attrname" index="1" name="Attribute name"/>
    <alias field="value" index="2" name="Value"/>
    <alias field="cityobject_id" index="3" name="Cityobject ID"/>
  </aliases>
  <defaults>
    <default expression="" applyOnUpdate="0" field="id"/>
    <default expression="" applyOnUpdate="0" field="attrname"/>
    <default expression="" applyOnUpdate="0" field="value"/>
    <default expression="" applyOnUpdate="0" field="cityobject_id"/>
  </defaults>
  <constraints>
    <constraint constraints="3" exp_strength="0" field="id" unique_strength="1" notnull_strength="1"/>
    <constraint constraints="1" exp_strength="0" field="attrname" unique_strength="0" notnull_strength="1"/>
    <constraint constraints="1" exp_strength="0" field="value" unique_strength="0" notnull_strength="1"/>
    <constraint constraints="0" exp_strength="0" field="cityobject_id" unique_strength="0" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="id"/>
    <constraint desc="" exp="" field="attrname"/>
    <constraint desc="" exp="" field="value"/>
    <constraint desc="" exp="" field="cityobject_id"/>
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
    <attributeEditorField showLabel="1" index="0" name="id"/>
    <attributeEditorField showLabel="1" index="1" name="attrname"/>
    <attributeEditorField showLabel="1" index="2" name="value"/>
    <attributeEditorField showLabel="1" index="3" name="cityobject_id"/>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="attrname"/>
    <field editable="0" name="cityobject_id"/>
    <field editable="0" name="id"/>
    <field editable="0" name="parent_genattrib_id"/>
    <field editable="0" name="root_genattrib_id"/>
    <field editable="1" name="value"/>
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
