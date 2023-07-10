<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="acquisitionmethod">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="data_model = 'Energy ADE 1.0' AND name = 'AcquisitionMethodValue'" name="FilterExpression" type="QString"/>
            <Option value="value" name="Key" type="QString"/>
            <Option value="ade3_v_enumeration_value_6de1bfc8_629a_4744_95b5_2092801c1b58" name="Layer" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="description" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="interpolationtype">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="data_model = 'Energy ADE 1.0' AND name = 'InterpolationTypeValue'" name="FilterExpression" type="QString"/>
            <Option value="value" name="Key" type="QString"/>
            <Option value="ade3_v_enumeration_value_6de1bfc8_629a_4744_95b5_2092801c1b58" name="Layer" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="description" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="qualitydescription">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="source">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="thematicdescription">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" name="Database ID" index="0"/>
    <alias field="acquisitionmethod" name="Acquisition Method" index="1"/>
    <alias field="interpolationtype" name="Interpolation Type" index="2"/>
    <alias field="qualitydescription" name="Quality Description" index="3"/>
    <alias field="source" name="Source" index="4"/>
    <alias field="thematicdescription" name="Thematic Description" index="5"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint field="id" constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1"/>
  </constraints>
  <constraintExpressions>
  </constraintExpressions>
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
    <attributeEditorField name="acquisitionmethod" showLabel="1" index="1"/>
    <attributeEditorField name="interpolationtype" showLabel="1" index="2"/>
    <attributeEditorField name="qualitydescription" showLabel="1" index="3"/>
    <attributeEditorField name="source" showLabel="1" index="4"/>
    <attributeEditorField name="thematicdescription" showLabel="1" index="5"/>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="id"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
