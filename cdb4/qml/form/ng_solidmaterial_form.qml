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
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
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
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="lineage">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="conductivity">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="conductivity_uom">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="density">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="density_uom">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="permeance">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="permeance_uom">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="specificheat">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="specificheat_uom">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
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
    <alias field="termination_date" name="Termination Date" index="7"/>
    <alias field="last_modification_date" name="Last Modification Date" index="10"/>
    <alias field="updating_person" name="Updating Person" index="11"/>
    <alias field="reason_for_update" name="Reason for Update" index="12"/>
    <alias field="lineage" name="Lineage" index="13"/>
    <alias field="conductivity" name="Conductivity" index="14"/>
    <alias field="conductivity_uom" name="Conductivity UoM" index="15"/>
    <alias field="density" name="Density" index="16"/>
    <alias field="density_uom" name="Density UoM" index="17"/>
    <alias field="permeance" name="Permeance" index="18"/>
    <alias field="permeance_uom" name="Permeance UoM" index="19"/>
    <alias field="specificheat" name="Specific Heat" index="20"/>
    <alias field="specificheat_uom" name="Specific Heat UoM" index="21"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint field="id" constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1"/>
    <constraint field="conductivity" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="conductivity_uom" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="density" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="density_uom" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="permeance" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="permeance_uom" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="specificheat" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
    <constraint field="specificheat_uom" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="conductivity" desc="Both values must either be NULL or NOT NULL" exp="(&quot;conductivity&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;conductivity_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;conductivity&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;conductivity_uom&quot; IS NULL)"/>
    <constraint field="conductivity_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;conductivity&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;conductivity_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;conductivity&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;conductivity_uom&quot; IS NULL)"/>
    <constraint field="density" desc="Both values must either be NULL or NOT NULL" exp="(&quot;density&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;density_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;density&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;density_uom&quot; IS NULL)"/>
    <constraint field="density_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;density&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;density_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;density&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;density_uom&quot; IS NULL)"/>
    <constraint field="permeance" desc="Both values must either be NULL or NOT NULL" exp="(&quot;permeance&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;permeance_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;permeance&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;permeance_uom&quot; IS NULL)"/>
    <constraint field="permeance_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;permeance&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;permeance_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;permeance&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;permeance_uom&quot; IS NULL)"/>
    <constraint field="specificheat" desc="Both values must either be NULL or NOT NULL" exp="(&quot;specificheat&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;specificheat_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;specificheat&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;specificheat_uom&quot; IS NULL)"/>
    <constraint field="specificheat_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;specificheat&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;specificheat_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;specificheat&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;specificheat_uom&quot; IS NULL)"/>
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
<!-- Parent/root attributes BEGIN -->
<!-- Parent/root attributes END -->	
    </attributeEditorContainer>
<!-- database info tab -->  
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer visibilityExpression="" groupBox="1" name="Feature-specific attributes" columnCount="2" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="conductivity" showLabel="1" index="14"/>
      <attributeEditorField name="conductivity_uom" showLabel="1" index="15"/>
      <attributeEditorField name="density" showLabel="1" index="16"/>
      <attributeEditorField name="density_uom" showLabel="1" index="17"/>
      <attributeEditorField name="permeance" showLabel="1" index="18"/>
      <attributeEditorField name="permeance_uom" showLabel="1" index="19"/>
      <attributeEditorField name="specificheat" showLabel="1" index="20"/>
      <attributeEditorField name="specificheat_uom" showLabel="1" index="21"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="1" name="description"/>
    <field editable="1" name="gmlid"/>
    <field editable="1" name="gmlid_codespace"/>
    <field editable="1" name="id"/>
    <field editable="1" name="last_modification_date"/>
    <field editable="1" name="lineage"/>
    <field editable="1" name="name"/>
    <field editable="1" name="name_codespace"/>
    <field editable="1" name="reason_for_update"/>
    <field editable="1" name="termination_date"/>
    <field editable="1" name="updating_person"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
