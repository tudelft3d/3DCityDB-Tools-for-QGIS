<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="cityobject_demands_id">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="enduse">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="data_model = 'Energy ADE 1.0' AND name = 'EndUseTypeValue'" name="FilterExpression" type="QString"/>
            <Option value="value" name="Key" type="QString"/>
            <Option value="ade3_v_enumeration_value_3d7faac5_2f33_486f_b7dc_5515dc2ffc44" name="Layer" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="description" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="energyamount_id">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="energycarriertype">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="energycarriertype_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="maximumload">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="maximumload_uom">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" name="Database ID" index="0"/>
    <alias field="cityobject_demands_id" name="" index="1"/>
    <alias field="enduse" name="End Use" index="2"/>
    <alias field="energyamount_id" name="Energy Amount ID" index="3"/>
    <alias field="energycarriertype" name="Energy Carrier Type" index="4"/>
    <alias field="energycarriertype_codespace" name="Energy Carrier Type Codespace" index="5"/>
    <alias field="maximumload" name="Maximum Load" index="6"/>
    <alias field="maximumload_uom" name="Maximum Load UoM" index="7"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint field="id" constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1"/>
    <constraint field="maximumload" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="maximumload_uom" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="maximumload" desc="Both values must either be NULL or NOT NULL" exp="(&quot;maximumload&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;maximumload_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;maximumload&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;maximumload_uom&quot; IS NULL)"/>
    <constraint field="maximumload_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;maximumload&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;maximumload_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;maximumload&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;maximumload_uom&quot; IS NULL)"/>
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
    <attributeEditorField name="cityobject_demands_id" showLabel="1" index="1"/>
    <attributeEditorField name="enduse" showLabel="1" index="2"/>
    <attributeEditorField name="energyamount_id" showLabel="1" index="3"/>
    <attributeEditorField name="energycarriertype" showLabel="1" index="4"/>
    <attributeEditorField name="energycarriertype_codespace" showLabel="1" index="5"/>
    <attributeEditorField name="maximumload" showLabel="1" index="6"/>
    <attributeEditorField name="maximumload_uom" showLabel="1" index="7"/>
    <attributeEditorContainer name="RegularTimeSeries" visibilityExpressionEnabled="0" showLabel="0" groupBox="1" visibilityExpression="" columnCount="2">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_reference" relation="id_re_xx" label="Form RegularTimeSeries" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="cityobject_demands_id"/>
    <field editable="0" name="energyamount_id"/>
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
