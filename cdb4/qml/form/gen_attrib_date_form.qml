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
    <field name="attrname" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="value" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="false"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd/MM/yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd/MM/yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="cityobject_id" configurationFlags="None">
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
    <alias name="Database ID" field="id" index="0"/>
    <alias name="Attribute name" field="attrname" index="1"/>
    <alias name="Value" field="value" index="2"/>
    <alias name="Cityobject ID" field="cityobject_id" index="3"/>
  </aliases>
  <defaults></defaults>
  <constraints>
    <constraint constraints="3" unique_strength="2" exp_strength="0" field="id" notnull_strength="2"/>
    <constraint constraints="1" unique_strength="0" exp_strength="0" field="attrname" notnull_strength="1"/>
    <constraint constraints="1" unique_strength="0" exp_strength="0" field="value" notnull_strength="1"/>
  </constraints>
  <constraintExpressions></constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorField name="id" showLabel="1" index="0"/>
    <attributeEditorField name="attrname" showLabel="1" index="1"/>
    <attributeEditorField name="value" showLabel="1" index="2"/>
    <attributeEditorField name="cityobject_id" showLabel="1" index="3"/>
  </attributeEditorForm>
  <editable>
    <field name="cityobject_id" editable="0"/>
    <field name="id" editable="0"/>
    <field name="parent_genattrib_id" editable="0"/>
    <field name="root_genattrib_id" editable="0"/>
  </editable>
  <labelOnTop></labelOnTop>
  <reuseLastValue></reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
