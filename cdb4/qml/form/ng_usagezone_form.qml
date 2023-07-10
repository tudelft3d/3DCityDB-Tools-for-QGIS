<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.4-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <field name="co_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="ng_co_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
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
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToTerrainType'"/>
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
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToWaterType'"/>
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
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="building_usagezone_id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="coolingschedule_id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="heatingschedule_id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="thermalzone_contains_id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="usagezonetype" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="usagezonetype_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ventilationschedule_id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="Database ID" field="co_id" index="0"/>
    <alias name="Database ID (ng)" field="ng_co_id" index="1"/>
    <alias name="Database ID" field="id" index="2"/>
    <alias name="GML ID" field="gmlid" index="3"/>
    <alias name="GML ID Codespace" field="gmlid_codespace" index="4"/>
    <alias name="Name" field="name" index="5"/>
    <alias name="Name Codespace" field="name_codespace" index="6"/>
    <alias name="Description" field="description" index="7"/>
    <alias name="Creation Date" field="creation_date" index="8"/>
    <alias name="Termination Date" field="termination_date" index="9"/>
    <alias name="Relative to Terrain" field="relative_to_terrain" index="10"/>
    <alias name="Relative to Water" field="relative_to_water" index="11"/>
    <alias name="Last Modification Date" field="last_modification_date" index="12"/>
    <alias name="Updating Person" field="updating_person" index="13"/>
    <alias name="Reason for Update" field="reason_for_update" index="14"/>
    <alias name="Lineage" field="lineage" index="15"/>
    <alias name="Building Usagezone ID" field="building_usagezone_id" index="16"/>
    <alias name="Cooling Schedule ID" field="coolingschedule_id" index="17"/>
    <alias name="Heating Schedule ID" field="heatingschedule_id" index="18"/>
    <alias name="Thermalzone Contains ID" field="thermalzone_contains_id" index="19"/>
    <alias name="Usagezone Type" field="usagezonetype" index="20"/>
    <alias name="Usagezone Type Codespace" field="usagezonetype_codespace" index="21"/>
    <alias name="Ventilation Schedule ID" field="ventilationschedule_id" index="22"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint constraints="3" field="co_id" exp_strength="0" notnull_strength="1" unique_strength="1"/>
    <constraint constraints="4" field="ng_co_id" exp_strength="0" notnull_strength="0" unique_strength="1"/>
    <constraint constraints="3" field="id" exp_strength="0" notnull_strength="1" unique_strength="1"/>
    <constraint constraints="3" field="building_usagezone_id" exp_strength="0" notnull_strength="1" unique_strength="0"/>
    <constraint constraints="3" field="coolingschedule_id" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint constraints="3" field="heatingschedule_id" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint constraints="3" field="thermalzone_contains_id" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint constraints="4" field="usagezonetype" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint constraints="4" field="usagezonetype_codespace" exp_strength="0" notnull_strength="0" unique_strength="0"/>
    <constraint constraints="3" field="ventilationschedule_id" exp_strength="0" notnull_strength="0" unique_strength="0"/>
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
    <!-- cityobject atts -->
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="description" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid" showLabel="1" index="2"/>   
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="3"/>
      <attributeEditorField name="name" showLabel="1" index="4"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="5"/>
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
    <!-- relation to surface -->
    <attributeEditorContainer name="Relation to surface" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
    <!-- external references -->
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
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <!--generic atts -->
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
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <!-- other atts -->
    <attributeEditorContainer name="Feature-specific Attributes" visibilityExpressionEnables="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="building_usagezone_id" showLabel="1" index="14"/>
      <attributeEditorField name="coolingschedule_id" showLabel="1" index="15"/>
      <attributeEditorField name="heatingschedule_id" showLabel="1" index="16"/>
      <attributeEditorField name="thermalzone_contains_id" showLabel="1" index="17"/> 
      <attributeEditorField name="ventilationschedule_id" showLabel="1" index="18"/>
      <attributeEditorField name="usagezonetype" showLabel="1" index="19"/> 
      <attributeEditorField name="usagezonetype_codespace" showLabel="1" index="20"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="building_usagezone_id"/>
    <field editable="0" name="co_id"/>
    <field editable="0" name="coolingschedule_id"/>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="heatingschedule_id"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="lineage"/>
    <field editable="0" name="ng_co_id"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="thermalzone_contains_id"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="ventilationschedule_id"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
