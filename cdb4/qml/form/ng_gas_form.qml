<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="creation_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="yyyy" type="QString"/>
            <Option name="field_format" value="yyyy" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="termination_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="yyyy" type="QString"/>
            <Option name="field_format" value="yyyy" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="last_modification_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="yyyy" type="QString"/>
            <Option name="field_format" value="yyyy" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="updating_person">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="lineage">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="isventilated">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="rvalue">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="rvalue_uom">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" name="Database ID" index="0"/>
    <alias field="gmlid" name="GML ID" index="1"/>
    <alias field="gmlid_codespace" name="GML ID Codespace" index="2"/>
    <alias field="name" name="Name" index="3"/>
    <alias field="name_codespace" name="Name Codespace" index="4"/>
    <alias field="description" name="Description" index="5"/>
    <alias field="creation_date" name="Creation Date" index="6"/>
    <alias field="termination_date" name="Termination" index="7"/>
    <alias field="last_modification_date" name="Last Modification Date" index="10"/>
    <alias field="updating_person" name="Updating Person" index="11"/>
    <alias field="reason_for_update" name="Reason for Update" index="12"/>
    <alias field="lineage" name="Lineage" index="13"/>
    <alias field="isventilated" name="Is Ventilated" index="14"/>
    <alias field="rvalue" name="R-value" index="15"/>
    <alias field="rvalue_uom" name="R-value UoM" index="16"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint field="id" constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1"/>
    <constraint field="rvalue" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="rvalue_uom" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="rvalue" desc="Both values must either be NULL or NOT NULL" exp="(&quot;rvalue&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;rvalue_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;rvalue&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;rvalue_uom&quot; IS NULL)"/>
    <constraint field="rvalue_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;rvalue&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;rvalue_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;rvalue&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;rvalue_uom&quot; IS NULL)"/>
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
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Feature-specific attributes" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2"> 
      <attributeEditorField name="isventilated" showLabel="1" index="14"/>
      <attributeEditorField name="rvalue" showLabel="1" index="15"/>
      <attributeEditorField name="rvalue_uom" showLabel="1" index="16"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="lineage"/>
    <field editable="0" name="name"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="updating_person"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
