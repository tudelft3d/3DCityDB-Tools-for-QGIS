<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.7-Białowieża">
  <fieldConfiguration>
<!-- cityobject attributes -->
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="creation_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
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
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_terrain">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="value" type="QString"/>
            <Option name="Layer" value="_v_enumeration_value_" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="description" type="QString"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_water">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="value" type="QString"/>
            <Option name="Layer" value="_v_enumeration_value_" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="description" type="QString"/>
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
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="updating_person">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="lineage">
      <editWidget type="TextEdit"></editWidget>
    </field>
<!-- cfu attributes -->
    <field configurationFlags="None" name="class">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="class_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="function">
      <editWidget type="List">
        <config>
          <Option type="Map">
            <Option name="EmptyIsEmptyArray" value="false" type="bool"/>
            <Option name="EmptyIsNull" value="true" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="function_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="usage">
      <editWidget type="List">
        <config>
          <Option type="Map">
            <Option name="EmptyIsEmptyArray" value="false" type="bool"/>
            <Option name="EmptyIsNull" value="true" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="usage_codespace">
      <editWidget type="TextEdit">
	  </editWidget>
    </field>
<!-- other attributes -->
    <field configurationFlags="None" name="year_of_construction">
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
    <field configurationFlags="None" name="year_of_demolition">
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
    <field configurationFlags="None" name="roof_type">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="roof_type_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="measured_height">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="measured_height_unit">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="storeys_above_ground">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="storeys_below_ground">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="storey_heights_above_ground">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="storey_heights_ag_unit">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="storey_heights_below_ground">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="storey_heights_bg_unit">
      <editWidget type="TextEdit"></editWidget>
    </field>
<!-- root/parent attributes -->
    <field name="building_parent_id" configurationFlags="None">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field name="building_root_id" configurationFlags="None">
      <editWidget type="TextEdit"></editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0"  name="Database ID" field="id"/>
    <alias index="1"  name="GML ID" field="gmlid"/>
    <alias index="2"  name="GML codespace" field="gmlid_codespace"/>
    <alias index="3"  name="Name" field="name"/>
    <alias index="4"  name="Name codespace" field="name_codespace"/>
    <alias index="5"  name="Description" field="description"/>
    <alias index="6"  name="Creation date" field="creation_date"/>
    <alias index="7"  name="Termination date" field="termination_date"/>
    <alias index="8"  name="Relative to terrain" field="relative_to_terrain"/>
    <alias index="9"  name="Relative to water" field="relative_to_water"/>
    <alias index="10" name="Last modification" field="last_modification_date"/>
    <alias index="11" name="Updating person" field="updating_person"/>
    <alias index="12" name="Reason for update" field="reason_for_update"/>
    <alias index="13" name="Lineage" field="lineage"/>
<!-- cfu attributes -->
    <alias index="14" name="Class" field="class"/>
    <alias index="15" name="Codespace" field="class_codespace"/>
    <alias index="16" name="Function" field="function"/>
    <alias index="17" name="Codespace" field="function_codespace"/>
    <alias index="18" name="Usage" field="usage"/>
    <alias index="19" name="Codespace" field="usage_codespace"/>
<!-- other attributes -->
    <alias index="20" name="Year of construction" field="year_of_construction"/>
    <alias index="21" name="Year of demolition" field="year_of_demolition"/>
    <alias index="22" name="Roof type" field="roof_type"/>
    <alias index="23" name="Codespace" field="roof_type_codespace"/>
    <alias index="24" name="Height" field="measured_height"/>
    <alias index="25" name="UoM" field="measured_height_unit"/>
    <alias index="26" name="Storeys above ground" field="storeys_above_ground"/>
    <alias index="27" name="Storeys below ground" field="storeys_below_ground"/>
    <alias index="28" name="Storey height above ground" field="storey_heights_above_ground"/>
    <alias index="29" name="UoM" field="storey_heights_ag_unit"/>
    <alias index="30" name="Storey height below ground" field="storey_heights_below_ground"/>
    <alias index="31" name="UoM" field="storey_heights_bg_unit"/>
<!-- parent/root attributes -->
    <alias index="101" name="Database parent ID" field="building_parent_id"/>
    <alias index="102" name="Database root ID" field="building_root_id"/>
  </aliases>
  <defaults></defaults>
  <constraints>
    <constraint constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1" field="id"/>
<!-- other attributes -->	
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="measured_height"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="measured_height_unit"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storeys_above_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storeys_below_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_above_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_ag_unit"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_below_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_bg_unit"/>
  </constraints>
  <constraintExpressions>
    <constraint field="measured_height" desc="BOTH values must be either NULL or not NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)"/>
    <constraint field="measured_height_unit" desc="BOTH values must be either NULL or not NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)"/>
    <constraint field="storeys_above_ground" desc="Number must be >= 0" exp="(&quot;storeys_above_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_above_ground&quot; >= 0)"/>
    <constraint field="storeys_below_ground" desc="Number must be >= 0" exp="(&quot;storeys_below_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_below_ground&quot; >= 0)"/>
    <constraint field="storey_heights_above_ground" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)"/>
    <constraint field="storey_heights_ag_unit" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)"/>
    <constraint field="storey_heights_below_ground" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)"/>
    <constraint field="storey_heights_bg_unit" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)"/>
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
<!-- cityobject tabs with attributes -->  
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Main Info" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="id" showLabel="1" index="0"/>
<!-- Parent/root attributes BEGIN -->
      <attributeEditorField name="building_parent_id" showLabel="1" index="101"/>
      <attributeEditorField name="building_root_id" showLabel="1" index="102"/>
<!-- Parent/root attributes END -->	  
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Database Info" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Relation to surface" columnCount="1" showLabel="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
<!--     <attributeEditorContainer name="External references" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="_xx_external_reference_placeholder_id_xx_" nmRelationId="" showLabel="0" label="External References" forceSuppressFormPopup="0" relation="_xx_rel_eternaal_references_placeholder_id_xx_" relationWidgetTypeId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer> -->
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Generic Attributes" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorRelation relationWidgetTypeId="" label="Generic Attributes" name="_x_co_genatt_id_x_" relation="_x_rel_id_x_" showLabel="0" forceSuppressFormPopup="0" nmRelationId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer>
<!--     <attributeEditorContainer name="Address(es)" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="_xx_addresses_placeholder_id_xx_" nmRelationId="" showLabel="0" label="Generic Attributes" forceSuppressFormPopup="0" relation="_xx_relation_addresses_placeholder_id_xx_" relationWidgetTypeId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer> -->	
<!-- just an empty line -->
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
<!-- cfu attributes -->
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Class" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="class" showLabel="1" index="14"/>
      <attributeEditorField name="class_codespace" showLabel="1" index="15"/>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Function" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="function" showLabel="1" index="16"/>
      <attributeEditorField name="function_codespace" showLabel="1" index="17"/>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Usage" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="usage" showLabel="1" index="18"/>
      <attributeEditorField name="usage_codespace" showLabel="1" index="19"/>
    </attributeEditorContainer>
<!-- just an empty line -->
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
<!-- other attributes -->
    <attributeEditorContainer visibilityExpression="" groupBox="1" name="Feature-specific attributes" columnCount="2" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="year_of_construction" showLabel="1" index="20"/>
      <attributeEditorField name="year_of_demolition" showLabel="1" index="21"/>
      <attributeEditorField name="storeys_above_ground" showLabel="1" index="26"/>
      <attributeEditorField name="storeys_below_ground" showLabel="1" index="27"/>
      <attributeEditorField name="measured_height" showLabel="1" index="24"/>
      <attributeEditorField name="measured_height_unit" showLabel="1" index="25"/>
      <attributeEditorField name="storey_heights_above_ground" showLabel="1" index="28"/>
      <attributeEditorField name="storey_heights_ag_unit" showLabel="1" index="29"/>
      <attributeEditorField name="storey_heights_below_ground" showLabel="1" index="30"/>
      <attributeEditorField name="storey_heights_bg_unit" showLabel="1" index="31"/>
      <attributeEditorField name="roof_type" showLabel="1" index="22"/>
      <attributeEditorField name="roof_type_codespace" showLabel="1" index="23"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="id"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="creation_date"/>	
    <field editable="0" name="termination_date"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="lineage"/>
<!-- cfu attributes -->
    <field editable="0" name="class_codespace"/>
    <field editable="0" name="function_codespace"/>
    <field editable="0" name="usage_codespace"/>
<!-- other attributes -->
    <field editable="0" name="roof_type_codespace"/>
<!-- parent and root attributes -->
    <field editable="0" name="building_root_id"/>
    <field editable="0" name="building_parent_id"/>
  </editable>
  <labelOnTop></labelOnTop>
  <reuseLastValue></reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
</qgis>
