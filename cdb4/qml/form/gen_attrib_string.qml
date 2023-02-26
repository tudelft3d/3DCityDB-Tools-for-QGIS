<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.16-Białowieża" styleCategories="Fields|Forms">
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
    <field configurationFlags="None" name="parent_genattrib_id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="root_genattrib_id">
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
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" type="bool" name="IsMultiline"/>
            <Option value="false" type="bool" name="UseHtml"/>
          </Option>
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
    <alias name="Database ID" field="id" index="0"/>
    <alias name="" field="parent_genattrib_id" index="1"/>
    <alias name="" field="root_genattrib_id" index="2"/>
    <alias name="Attribute name" field="attrname" index="3"/>
    <alias name="Value" field="value" index="4"/>
    <alias name="Cityobject ID" field="cityobject_id" index="5"/>
  </aliases>
  <defaults>
    <default expression="" applyOnUpdate="0" field="id"/>
    <default expression="" applyOnUpdate="0" field="parent_genattrib_id"/>
    <default expression="" applyOnUpdate="0" field="root_genattrib_id"/>
    <default expression="" applyOnUpdate="0" field="attrname"/>
    <default expression="" applyOnUpdate="0" field="value"/>
    <default expression="" applyOnUpdate="0" field="cityobject_id"/>
  </defaults>
  <constraints>
    <constraint constraints="3" notnull_strength="1" exp_strength="0" unique_strength="1" field="id"/>
    <constraint constraints="0" notnull_strength="0" exp_strength="0" unique_strength="0" field="parent_genattrib_id"/>
    <constraint constraints="0" notnull_strength="0" exp_strength="0" unique_strength="0" field="root_genattrib_id"/>
    <constraint constraints="1" notnull_strength="1" exp_strength="0" unique_strength="0" field="attrname"/>
    <constraint constraints="1" notnull_strength="1" exp_strength="0" unique_strength="0" field="value"/>
    <constraint constraints="0" notnull_strength="0" exp_strength="0" unique_strength="0" field="cityobject_id"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="" field="id" desc=""/>
    <constraint exp="" field="parent_genattrib_id" desc=""/>
    <constraint exp="" field="root_genattrib_id" desc=""/>
    <constraint exp="" field="attrname" desc=""/>
    <constraint exp="" field="value" desc=""/>
    <constraint exp="" field="cityobject_id" desc=""/>
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
    <field reuseLastValue="0" name="attrname"/>
    <field reuseLastValue="0" name="cityobject_id"/>
    <field reuseLastValue="0" name="id"/>
    <field reuseLastValue="0" name="parent_genattrib_id"/>
    <field reuseLastValue="0" name="root_genattrib_id"/>
    <field reuseLastValue="0" name="value"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
