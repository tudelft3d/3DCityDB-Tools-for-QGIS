<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="co_id">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
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
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="termination_date">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="last_modification_date">
      <editWidget type="DateTime">
        <config>
          <Option/>
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
    <field configurationFlags="None" name="heatdissipation_id">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="numberofoccupants">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="occupancyrate_id">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="usagezone_occupiedby_id">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" name="Database ID" index="1"/>
    <alias field="gmlid" name="GML ID" index="2"/>
    <alias field="gmlid_codespace" name="GML ID Codespace" index="3"/>
    <alias field="name" name="Name" index="4"/>
    <alias field="name_codespace" name="Name Codespace" index="5"/>
    <alias field="description" name="Description" index="6"/>
    <alias field="creation_date" name="Creation Date" index="7"/>
    <alias field="termination_date" name="Termination Date" index="8"/>
    <alias field="last_modification_date" name="Last Modification Date" index="11"/>
    <alias field="updating_person" name="Updating Person" index="12"/>
    <alias field="reason_for_update" name="Reason for Update" index="13"/>
    <alias field="lineage" name="Lineage" index="14"/>
    <alias field="heatdissipation_id" name="Heat Dissipation ID" index="15"/>
    <alias field="numberofoccupants" name="Number of Occupants" index="16"/>
    <alias field="occupancyrate_id" name="Occupancy Rate ID" index="17"/>
    <alias field="usagezone_occupiedby_id" name="Usagezone Occupued By ID" index="18"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint field="co_id" constraints="0" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint field="numberofoccupants" constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="numberofoccupants" desc="" exp=""/>
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
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement> 
    <attributeEditorContainer name="HeatExchangeType" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement> 
    <attributeEditorContainer name="Feature-specific attributes" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="numberofoccupants" showLabel="1" index="16"/>
      <attributeEditorField name="occupancyrate_id" showLabel="1" index="17"/>
      <attributeEditorField name="heatdissipation_id" showLabel="1" index="15"/>
      <attributeEditorField name="usagezone_occupiedby_id" showLabel="1" index="18"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="co_id"/>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="description"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="heatdissipation_id"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="lineage"/>
    <field editable="0" name="name"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="occupancyrate_id"/>
    <field editable="0" name="relative_to_terrain"/>
    <field editable="0" name="relative_to_water"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="usagezone_occupiedby_id"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
