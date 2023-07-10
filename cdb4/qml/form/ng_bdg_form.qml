<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
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
    <field name="termination_date" configurationFlags="None">
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
    <field name="relative_to_terrain" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToTerrainType'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="ade3_v_enumeration_value_e36f6ece_8891_49ac_a872_d9038c05d3e7"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToWaterType'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="ade3_v_enumeration_value_e36f6ece_8891_49ac_a872_d9038c05d3e7"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
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
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
<!-- cfu atts -->
    <field name="class" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="class_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="function" configurationFlags="None">
      <editWidget type="List">
        <config>
          <Option type="Map">
	    <Option name="EmptyIsEmptyArray" value="false" type="bool"/>
            <Option name="EmptyIsNull" value="true" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="usage" configurationFlags="None">
      <editWidget type="List">
        <config>
          <Option type="Map">
            <Option name="EmptyIsEmptyArray" value="false" type="bool"/>
            <Option name="EmptyIsNull" value="true" type="bool"/>
	  </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
<!-- other atts -->
    <field name="year_of_construction" configurationFlags="None">
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
    <field name="year_of_demolition" configurationFlags="None">
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
    <field name="roof_type" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="roof_type_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="measured_height" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="measured_height_unit" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="storeys_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="storeys_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="storey_heights_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="storey_heights_ag_unit" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="storey_heights_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="storey_heights_bg_unit" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="ng_co_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="ng_b_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="buildingtype" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'Energy ADE 1.0' AND name = 'BuildingTypeValue'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="_v_codelist_value_"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="buildingtype_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="constructionweight" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'Energy ADE 1.0' AND name = 'ConstructionWeightValue'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="_v_enumeration_value_"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="true"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
	  </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="Database ID" index="0" field="id"/>
    <alias name="GML ID" index="1" field="gmlid"/>
    <alias name="GML codespace" index="2" field="gmlid_codespace"/>
    <alias name="Name" index="3" field="name"/>
    <alias name="Name codespace" index="4" field="name_codespace"/>
    <alias name="Description" index="5" field="description"/>
    <alias name="Creation date" index="6" field="creation_date"/>
    <alias name="Termination date" index="7" field="termination_date"/>
    <alias name="Relative to terrain" index="8" field="relative_to_terrain"/>
    <alias name="Relative to water" index="9" field="relative_to_water"/>
    <alias name="Last modification date" index="10" field="last_modification_date"/>
    <alias name="Updating person" index="11" field="updating_person"/>
    <alias name="Reason for update" index="12" field="reason_for_update"/>
    <alias name="Lineage" index="13" field="lineage"/>
    <alias name="Class" index="14" field="class"/>
    <alias name="Class codespace" index="15" field="class_codespace"/>
    <alias name="Function" index="16" field="function"/>
    <alias name="Function codespace" index="17" field="function_codespace"/>
    <alias name="Usage" index="18" field="usage"/>
    <alias name="Usage codespace" index="19" field="usage_codespace"/>
    <alias name="Year of construction" index="20" field="year_of_construction"/>
    <alias name="Year of demolition" index="21" field="year_of_demolition"/>
    <alias name="Roof type" index="22" field="roof_type"/>
    <alias name="Roof type codespace" index="23" field="roof_type_codespace"/>
    <alias name="Height" index="24" field="measured_height"/>
    <alias name="Height UoM" index="25" field="measured_height_unit"/>
    <alias name="Storeys above ground" index="26" field="storeys_above_ground"/>
    <alias name="Storeys below ground" index="27" field="storeys_below_ground"/>
    <alias name="Storey height above ground" index="28" field="storey_heights_above_ground"/>
    <alias name="Storey hag UoM" index="29" field="storey_heights_ag_unit"/>
    <alias name="Storey height below ground" index="30" field="storey_heights_below_ground"/>
    <alias name="Storey hbg UoM" index="31" field="storey_heights_bg_unit"/>
    <alias name="" index="32" field="ng_co_id"/>
    <alias name="" index="33" field="ng_b_id"/>
    <alias name="Building type" index="34" field="buildingtype"/>
    <alias name="Building type codespace" index="35" field="buildingtype_codespace"/>
    <alias name="Construction weight" index="36" field="constructionweight"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint exp_strength="0" unique_strength="1" notnull_strength="1" constraints="3" field="id"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="measured_height"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="measured_height_unit"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="storeys_above_ground"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="storeys_below_ground"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="storey_heights_above_ground"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="storey_heights_ag_unit"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="storey_heights_below_ground"/>
    <constraint exp_strength="1" unique_strength="0" notnull_strength="0" constraints="4" field="storey_heights_bg_unit"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="Both values must either be NULL or NOT NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot;IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot;IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot;IS NULL)" field="measured_height"/>
    <constraint desc="Both values must either be NULL or NOT NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot;IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot;IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot;IS NULL)" field="measured_height_unit"/>
    <constraint desc="Number must be >= 0" exp="(&quot;storeys_above_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_above_ground&quot; >= 0)" field="storeys_above_ground"/>
    <constraint desc="Number must be >= 0" exp="(&quot;storeys_below_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_below_ground&quot; >= 0)" field="storeys_below_ground"/>
    <constraint desc="Both values must either be NULL or NOT NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)" field="storey_heights_above_ground"/>
    <constraint desc="Both values must either be NULL or NOT NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)" field="storey_heights_ag_unit"/>
    <constraint desc="Both values must either be NULL or NOT NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)" field="storey_heights_below_ground"/>
    <constraint desc="Both values must either be NULL or NOT NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)" field="storey_heights_bg_unit"/>
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
    <!-- cityobject tab -->
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
    </attributeEditorContainer>
    <!-- database info -->
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <!-- relation to surface tab -->
    <attributeEditorContainer name="Relation to Surface" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
    <!-- external references tab -->
    <attributeEditorContainer name="Ext ref (Name)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_xx" label="Form Ext ref (Name)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Ext ref (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Ext ref (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <!-- addresses tab -->
    <attributeEditorContainer name="Addresses" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Addresses" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature|ZoomToChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <!-- just an empty line -->
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement> 
    <!-- generic atts tab -->
    <attributeEditorContainer name="Gen Attrib (String)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (String)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Integer)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Integer)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Real)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Real)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Measure)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Measure)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Date)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Date)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer> 
    <attributeEditorContainer name="FloorArea" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form FloorArea" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="VolumeType" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form VolumeType" showLabel="0" nmRelationId="">
	<editor_configuration type="Map">
	  <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
	  <Option name="show_first_feature" type="bool" value="true"/>
	</editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="HeightAboveGround" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form HeightAboveGround" showLabel="0" nmRelationId="">
	<editor_configuration type="Map">
	  <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
	  <Option name="show_first_feature" type="bool" value="true"/>
	</editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <!-- just an empty line -->
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <!-- cfu atts -->
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
    <!-- other atts -->
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
      <attributeEditorField name="buildingtype" showLabel="1" index="24"/> 
      <attributeEditorField name="buildingtype_codespace" showLabel="1" index="25"/>
      <attributeEditorField name="constructionweight" showLabel="1" index="26"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="buildingtype_codespace"/>
    <field editable="0" name="class_codespace"/>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="function_codespace"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="lineage"/>
    <field editable="0" name="ng_b_id"/>
    <field editable="0" name="ng_co_id"/>
    <field editable="0" name="roof_type_codespace"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="usage_codespace"/>
    <field editable="0" name="name_codespace"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>2</layerGeometryType>
</qgis>
